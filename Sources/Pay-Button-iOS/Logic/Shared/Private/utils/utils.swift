//
//  utils.swift
//  TapCardCheckOutKit
//
//  Created by Osama Rabie on 08/09/2023.
//

import Foundation
import UIKit
import CoreTelephony
import SharedDataModels_iOS

internal class UrlBasedUtils {
    //MARK: - Generate tap button sdk url methods
    /// The used intent id
    internal static var intentID:String = ""
    /// The key word we know that tap redirected the charge/authorize
    internal static var redirectionKeyWord:String = "tap_id"
    /// The used public key
    internal static var publicKey:String = ""
    /// The base url for this version when talking to the checkout mw
    internal static var checkoutMWBaseURL:String = "https://mw-sdk.dev.tap.company/v2/"
    /// The name of the sdk when upadting the intent with the sdk info. Same value the web pay button reports
    internal static var sdkType:String = "button"
    /// The version of the sdk when upadting the intent with the sdk info. Same value the web pay button reports
    internal static var sdkVersion:String = "2.2.0"
    /// The public key to use in case of sandbox transaction
    internal static var sandboxEncryptionKey:String = """
-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC8AX++RtxPZFtns4XzXFlDIxPB
h0umN4qRXZaKDIlb6a3MknaB7psJWmf2l+e4Cfh9b5tey/+rZqpQ065eXTZfGCAu
BLt+fYLQBhLfjRpk8S6hlIzc1Kdjg65uqzMwcTd0p7I4KLwHk1I0oXzuEu53fU1L
SZhWp4Mnd6wjVgXAsQIDAQAB
-----END PUBLIC KEY-----
"""
    /// The public key to use in case of production transaction
    internal static var productionEncryptionKey:String = """
-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC9hSRms7Ir1HmzdZxGXFYgmpi3
ez7VBFje0f8wwrxYS9oVoBtN4iAt0DOs3DbeuqtueI31wtpFVUMGg8W7R0SbtkZd
GzszQNqt/wyqxpDC9q+97XdXwkWQFA72s76ud7eMXQlsWKsvgwhY+Ywzt0KlpNC3
Hj+N6UWFOYK98Xi+sQIDAQAB
-----END PUBLIC KEY-----
"""
    /// The encryption public key for the Checkout MW
    internal static var publicEncryptionKey:String {
        if UrlBasedUtils.publicKey.contains("test") {
            return sandboxEncryptionKey
        }else{
            return productionEncryptionKey
        }
    }
    /// The button wrapper format url
    internal static var buttonWrapperUrlFormat:String = "https://button.dev.tap.company/?intentId=%@&publicKey=%@&mdn=%@&platform=mobile"
    /// Computes the corrcet button url with data and format
    internal static var buttonWrapperUrl:String {
        // The page has to report the same mdn the create intent & the sdk info calls reported, so we reuse the
        // one generated back then .. falling back to generating it here in case no sdk info has been built yet
        let mdn:String = currentSdkInfo.sdkInfo?.mdn ?? encryptedMdn(using: publicEncryptionKey)
        return String(format: buttonWrapperUrlFormat, currentInentID, currentSdkInfo.sdkInfo?.authorization ?? publicKey, mdn.toBase64())
    }
    /// Currently used intent id
    internal static var currentInentID:String = ""
    /// Currently used SDKInfo
    internal static var currentSdkInfo:SDKInfo = .init()
    /// The CDN file holding the base url & the encryption keys our backend wants us to use
    internal static let cdnConfigurationURL:String = "https://tap-sdks.b-cdn.net/mobile/paybutton/1.0.0/base_url.json"

    /// Loads the base url & the encryption keys from the CDN, then calls back regardless of the result
    /// as the embedded defaults are used as a fallback
    /// - Parameter completion: Called once the CDN data has been loaded and applied
    static func loadCDNConfiguration(completion: @escaping () -> Void = {}) {
        guard let url:URL = URL(string: cdnConfigurationURL) else {
            // Use the default embedded values as a fallback
            completion()
            return
        }
        var cdnRequest = URLRequest(url: url)
        cdnRequest.timeoutInterval = 2
        cdnRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        URLSession.shared.dataTask(with: cdnRequest) { data, response, error in
            applyCDNConfiguration(data: data)
            completion()
        }.resume()
    }

    /// Saves the data loaded from the CDN to be used afterwards
    /// - Parameter data: The data loaded from the CDN file
    static func applyCDNConfiguration(data: Data?) {
        guard let data = data else { return }
        do {
            if let cdnResponse:[String:String] = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String],
               let cdnBaseUrlString:String = cdnResponse["baseURL"], cdnBaseUrlString != "",
               let _:URL = URL(string: cdnBaseUrlString),
               let sandboxEncryptionKey:String = cdnResponse["testEncKey"],
               let buttonWrapperUrlFormat:String = cdnResponse["payButtonUrlFormat"],
               let productionEncryptionKey:String = cdnResponse["prodEncKey"],
               let fireBaseURL:String = cdnResponse["iOSFirebaseURL"],
               let fireBaseJS:String = cdnResponse["iOSFireBaseJS"],
               let redirectionKeyWord:String = cdnResponse["redirectionKeyWord"] {
                UrlBasedUtils.sandboxEncryptionKey = sandboxEncryptionKey
                UrlBasedUtils.productionEncryptionKey = productionEncryptionKey
                UrlBasedUtils.checkoutMWBaseURL = cdnBaseUrlString
                UrlBasedUtils.buttonWrapperUrlFormat = buttonWrapperUrlFormat
                UrlBasedUtils.redirectionKeyWord = redirectionKeyWord
                // The button holds these on the main actor, and the callers hop to main right after us so the ordering holds
                DispatchQueue.main.async {
                    BenefitPayButton.benefitPayFireBaseURL = fireBaseURL
                    BenefitPayButton.javaScriptCodeToSkipManInTheMiddle = fireBaseJS
                }
            }
        } catch {}
    }

    ///  Creates an intent out of the passed intent configuration object. Mirrors the web sdk's create intent flow:
    ///  the configuration is posted as is to the checkout mw and the sdk info is attached as a sibling `sdk_info` key
    ///  - Parameter from config: The intent configuration object as passed by the merchant
    ///  - Parameter with sdkInfo: The SDK info to attach to the created intent
    static func createIntent(from config:[String:Any], with sdkInfo:SDKInfo, completion: @escaping (_ response:[String:Any]?, _ error:String?) -> Void = {response,error in }) throws {
        do {
            // Store for further reference
            currentSdkInfo = sdkInfo
            // The web sdk posts the configuration at the root and adds the sdk info next to it
            var body:[String:Any] = config
            body["sdk_info"] = sdkInfo.sdkInfo?.dictionary ?? [:]
            let data = try JSONSerialization.data(withJSONObject: body, options: [])
            // construct the create intent url
            let createIntentURL = "\(checkoutMWBaseURL)intent"

            var request = URLRequest(url: URL(string: createIntentURL)!)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.httpMethod = "POST"
            request.httpBody = data
            // The mw authenticates the call with the merchant's public key, no secret key is needed
            request.setValue(sdkInfo.sdkInfo?.authorization ?? "", forHTTPHeaderField: "Authorization")
            request.setValue(sdkInfo.sdkInfo?.mdn ?? "", forHTTPHeaderField: "mdn")
            request.setValue(sdkInfo.sdkInfo?.application ?? "", forHTTPHeaderField: "application")

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard
                    let data = data,
                    let response = response as? HTTPURLResponse,
                    error == nil
                else {                                                               // check for fundamental networking error
                    completion(nil,"network error \(error?.localizedDescription ?? URLError(.badServerResponse).localizedDescription)")
                    return
                }

                guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                    completion(nil,"api error \(String(data: data, encoding: .utf8) ?? "status code \(response.statusCode)")")
                    return
                }

                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    // Keep the created intent id around, the button url is built out of it
                    if let intentID:String = jsonObject?["id"] as? String, !intentID.isEmpty {
                        currentInentID = intentID
                        UrlBasedUtils.intentID = intentID
                    }
                    completion(jsonObject, nil)
                } catch {
                    if let responseString = String(data: data, encoding: .utf8) {
                        completion(nil, "response error \(responseString) \(error)")
                    } else {
                        completion(nil, "response error \(error)")
                    }
                }
            }

            task.resume()
        }catch {
            throw error
        }
    }
    ///  Updates the intent with the required device data. Called before using the intent
    ///  - Parameter for intentID: The id of the intent
    ///  - Parameter with sdkInfo: The SDK info to update the intent with
    static func updateSDKInfo(for intentID:String, with sdkInfo:SDKInfo, completion: @escaping (_ response:[String:Any]?, _ error:String?) -> Void = {response,error in }) throws {
        do {
            // Store for further reference
            currentSdkInfo = sdkInfo
            currentInentID = intentID
            // The web sdk puts the sdk info fields at the root of the body, not wrapped inside an `sdk_info` key
            let data = try sdkInfo.sdkInfo?.jsonData() ?? Data()
            // construct the update sdkinfo intent url
            let updateSDKInfoURL = "\(checkoutMWBaseURL)intent/\(intentID)/sdk"
            
            var request = URLRequest(url: URL(string: updateSDKInfoURL)!)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "PUT"
            request.httpBody = data
            request.setValue(sdkInfo.sdkInfo?.authorization ?? "", forHTTPHeaderField: "Authorization")
            request.setValue(sdkInfo.sdkInfo?.mdn ?? "", forHTTPHeaderField: "mdn")
            request.setValue(sdkInfo.sdkInfo?.application ?? "", forHTTPHeaderField: "application")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard
                    let data = data,
                    let response = response as? HTTPURLResponse,
                    error == nil
                else {                                                               // check for fundamental networking error
                    print("error", error ?? URLError(.badServerResponse).localizedDescription)
                    //completion("", error?.localizedDescription ?? URLError(.badServerResponse).localizedDescription)
                    completion(nil,"network error \(error?.localizedDescription ?? URLError(.badServerResponse).localizedDescription)")
                    return
                }
                
                guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                    print("statusCode should be 2xx, but is \(response.statusCode), response \(response)")
                    print("response = \(response)")
                    //completion("", "statusCode should be 2xx, but is \(response.statusCode), response \(response)")
                    //completion()
                    completion(nil,"api error \(error?.localizedDescription ?? URLError(.badServerResponse).localizedDescription)")
                    return
                }
                
                // do whatever you want with the `data`, e.g.:
                
                do {
                    let responseObject = String(data: data, encoding: .utf8)
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    print(responseObject)
                    completion(jsonObject, nil)
                } catch {
                    print(error) // parsing error
                    
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("", "Unexpected response \(responseString) \(error)")
                        completion(nil, "response error \(responseString) \(error)")
                    } else {
                        print("", "unable to parse response as string \(error)")
                        completion(nil, "response error \(error)")
                    }
                    completion(nil, "response error \(error)")
                }
            }

            task.resume()
        }catch {
            throw error
        }
    }
    
    ///  Generates a card sdk url with correctly encoded values
    ///  - Parameter from configurations: the Dictionaty configurations to be url encoded
    ///  - Parameter payButtonType: The type you want to generate a url for
    static func generatePayButtonSdkURL(from configuration: [String : Any], payButtonType:PayButtonTypeEnum, completion: @escaping (_ buttonUrl:String, _ error:String) -> Void = {_,_ in}) throws -> String {
        do {
            // Make sure we have a valid string:any dictionaty
            let data = try JSONSerialization.data(withJSONObject: configuration, options: .prettyPrinted)
            //let jsonString = NSString(data: data, encoding: NSUTF8StringEncoding)
            // ul encode the generated string
            //let urlEncodedJson = jsonString!.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
            let urlString = "https://mw-sdk.dev.tap.company/v2/button/config"//"\(payButtonType.baseUrl())\(urlEncodedJson!)"
            
            var request = URLRequest(url: URL(string: urlString)!)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            
            request.httpBody = data

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard
                    let data = data,
                    let response = response as? HTTPURLResponse,
                    error == nil
                else {                                                               // check for fundamental networking error
                    print("error", error ?? URLError(.badServerResponse).localizedDescription)
                    completion("", error?.localizedDescription ?? URLError(.badServerResponse).localizedDescription)
                    return
                }
                
                guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                    print("statusCode should be 2xx, but is \(response.statusCode), response \(response)")
                    print("response = \(response)")
                    completion("", "statusCode should be 2xx, but is \(response.statusCode), response \(response)")
                    return
                }
                
                // do whatever you want with the `data`, e.g.:
                
                do {
                    let responseObject = try JSONDecoder().decode([String:String].self, from: data)
                    print(responseObject)
                    completion(responseObject["redirect_url"]!,"")
                } catch {
                    print(error) // parsing error
                    
                    if let responseString = String(data: data, encoding: .utf8) {
                        completion("", "Unexpected response \(responseString) \(error)")
                    } else {
                        completion("", "unable to parse response as string \(error)")
                    }
                }
            }

            task.resume()
                  // etc...
            
            return urlString
        }
        catch {
            throw error
        }
    }
    
    ///  Generates a card sdk url with correctly encoded values
    ///  - Parameter from configurations: the String configurations to be url encoded
    ///  - Parameter payButtonType: The type you want to generate a url for
    static func generatePayButtonSdkURL(from configuration: String, payButtonType:PayButtonTypeEnum, completion: @escaping () -> Void = {}) -> String {
        let urlEncodedJson = configuration.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
        // ul encode the generated string
        return "https://mw-sdk.dev.tap.company/v2/button/config"//"\(payButtonType.baseUrl())\(urlEncodedJson!)"
    }
    
    //MARK: - Network's headers
    
    /// The value we identify this integration with .. the app's bundle identifier
    internal static var mdnValue:String {
        return TapApplicationPlistInfo.shared.bundleIdentifier ?? ""
    }

    /// The already encrypted mdn, kept per encryption key
    private static var encryptedMdnCache:[String:String] = [:]

    /// Guards `encryptedMdnCache` .. the headers are generated from network callbacks as well as the main thread
    private static let encryptedMdnCacheLock:NSLock = .init()

    /// The encrypted mdn to report. RSA encryption is randomised, so encrypting the same mdn twice produces two
    /// different values. The backend correlates the mdn across the create intent call, the sdk info update, the
    /// button configuration and the button page, hence they all have to carry the exact same value .. we encrypt
    /// it once per encryption key and hand the very same result to every caller afterwards.
    /// - Parameter headersEncryptionPublicKey: The encryption key to be used
    static func encryptedMdn(using headersEncryptionPublicKey:String) -> String {
        encryptedMdnCacheLock.lock()
        defer { encryptedMdnCacheLock.unlock() }
        if let alreadyEncryptedMdn:String = encryptedMdnCache[headersEncryptionPublicKey] {
            return alreadyEncryptedMdn
        }
        let encryptedMdn:String = Crypter.encrypt(mdnValue, using: headersEncryptionPublicKey) ?? ""
        encryptedMdnCache[headersEncryptionPublicKey] = encryptedMdn
        return encryptedMdn
    }

    /// Generates the mdn & the application required headers
    /// - Parameter headersEncryptionPublicKey: The encryption key to be used
    static func generateApplicationHeader(headersEncryptionPublicKey:String) -> [String:String] {
        return [
            Constants.HTTPHeaderKey.application: applicationHeaderValue(headersEncryptionPublicKey: headersEncryptionPublicKey),
            Constants.HTTPHeaderKey.mdn: encryptedMdn(using: headersEncryptionPublicKey)
        ]
    }
    
    /// Generates the SDK INFO object
    /// - Parameter for publicKey: The public key passed by the merchant
    static func generateSDKINFO(for publicKey:String) -> SDKInfo {
        let headersInfo:[String:String] = UrlBasedUtils.generateApplicationHeader(headersEncryptionPublicKey: publicEncryptionKey)
        return .init(sdkInfo: .init(type: sdkType, version: sdkVersion, authorization: publicKey, mdn: headersInfo[Constants.HTTPHeaderKey.mdn], application: headersInfo[Constants.HTTPHeaderKey.application]))
    }
    
    
    /// HTTP headers that contains the device and app info
    /// - Parameter headersEncryptionPublicKey: The encryption key to be used
    static private func applicationHeaderValue(headersEncryptionPublicKey:String) -> String {
        
        var applicationDetails = applicationStaticDetails(headersEncryptionPublicKey: headersEncryptionPublicKey)
        
        let localeIdentifier = "en"
        
        applicationDetails[Constants.HTTPHeaderValueKey.appLocale] = localeIdentifier
        
        
        let result = (applicationDetails.map { "\($0.key)=\($0.value)" }).joined(separator: "|")
        
        return result
    }
    
    /// A computed variable that generates at access time the required static headers by the server.
    /// - Parameter headersEncryptionPublicKey: The encryption key to be used
    static func applicationStaticDetails(headersEncryptionPublicKey:String) -> [String: String] {
        
        /*guard let bundleID = TapApplicationPlistInfo.shared.bundleIdentifier, !bundleID.isEmpty else {
         
         fatalError("Application must have bundle identifier in order to use goSellSDK.")
         }*/
        
        let bundleID = TapApplicationPlistInfo.shared.bundleIdentifier ?? ""
        
        let sdkPlistInfo = TapBundlePlistInfo(bundle: Bundle(for: BenefitPayButton.self))
        guard let requirerVersion = sdkPlistInfo.shortVersionString, !requirerVersion.isEmpty else {
            
            fatalError("Seems like SDK is not integrated well.")
        }
        let networkInfo = CTTelephonyNetworkInfo()
        let providers = networkInfo.serviceSubscriberCellularProviders
        
        let osName = UIDevice.current.systemName
        let osVersion = UIDevice.current.systemVersion
        let deviceName = UIDevice.current.name
        let deviceNameFiltered =  deviceName.tap_byRemovingAllCharactersExcept("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ123456789 ()")
        let deviceType = UIDevice.current.model
        // The hardware identifier ex: iPhone15,2 .. not the localised marketing name
        let deviceModel = getDeviceCode() ?? ""
        let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? ""
        var simNetWorkName:String? = ""
        var simCountryISO:String? = ""

        if providers?.values.count ?? 0 > 0, let carrier:CTCarrier = providers?.values.first {
            simNetWorkName = carrier.carrierName
            simCountryISO = carrier.isoCountryCode
        }


        let result: [String: String] = [
            Constants.HTTPHeaderValueKey.appID: Crypter.encrypt(bundleID, using: headersEncryptionPublicKey) ?? "",
            Constants.HTTPHeaderValueKey.requirer: Crypter.encrypt(Constants.HTTPHeaderValueKey.requirerValue, using: headersEncryptionPublicKey) ?? "",
            Constants.HTTPHeaderValueKey.requirerVersion: Crypter.encrypt(requirerVersion, using: headersEncryptionPublicKey) ?? "",
            Constants.HTTPHeaderValueKey.requirerOS: Crypter.encrypt(osName, using: headersEncryptionPublicKey) ?? "",
            Constants.HTTPHeaderValueKey.requirerOSVersion: Crypter.encrypt(osVersion, using: headersEncryptionPublicKey) ?? "",
            Constants.HTTPHeaderValueKey.requirerDeviceName: Crypter.encrypt(deviceNameFiltered, using: headersEncryptionPublicKey) ?? "",
            Constants.HTTPHeaderValueKey.requirerDeviceType: Crypter.encrypt(deviceType, using: headersEncryptionPublicKey) ?? "",
            Constants.HTTPHeaderValueKey.requirerDeviceModel: Crypter.encrypt(deviceModel, using: headersEncryptionPublicKey) ?? "",
            Constants.HTTPHeaderValueKey.requirerSimNetworkName: Crypter.encrypt(simNetWorkName ?? "", using: headersEncryptionPublicKey) ?? "",
            Constants.HTTPHeaderValueKey.requirerSimCountryIso: Crypter.encrypt(simCountryISO ?? "", using: headersEncryptionPublicKey) ?? "",
            Constants.HTTPHeaderValueKey.deviceID: Crypter.encrypt(deviceID, using: headersEncryptionPublicKey) ?? "",
            Constants.HTTPHeaderValueKey.appType: Crypter.encrypt("app", using: headersEncryptionPublicKey) ?? ""
        ]

        return result
    }

    /// The hardware identifier of the device ex: iPhone15,2
    static func getDeviceCode() -> String? {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
            }
        }
        return modelCode
    }
    
    
    /// A constants for the network logs
    struct Constants {
        
        internal static let authenticateParameter = "authenticate"
        
        fileprivate static let timeoutInterval: TimeInterval            = 60.0
        fileprivate static let cachePolicy:     URLRequest.CachePolicy  = .reloadIgnoringCacheData
        
        fileprivate static let successStatusCodes = 200...299
        
        fileprivate struct HTTPHeaderKey {
            
            fileprivate static let authorization            = "Authorization"
            fileprivate static let application              = "application"
            fileprivate static let sessionToken             = "session_token"
            fileprivate static let contentTypeHeaderName    = "Content-Type"
            fileprivate static let token                    = "session"
            fileprivate static let mdn                      = "mdn"
            
            //@available(*, unavailable) private init() { }
        }
        
        fileprivate struct HTTPHeaderValueKey {
            
            fileprivate static let appID                    = "cu"
            fileprivate static let appLocale                = "al"
            fileprivate static let appType                  = "at"
            fileprivate static let deviceID                 = "di"
            fileprivate static let requirer                 = "aid"
            fileprivate static let requirerOS               = "ro"
            fileprivate static let requirerOSVersion        = "rov"
            fileprivate static let requirerValue            = "iOS-checkout-sdk"
            fileprivate static let requirerVersion          = "av"
            fileprivate static let requirerDeviceName       = "rn"
            fileprivate static let requirerDeviceType       = "rt"
            fileprivate static let requirerDeviceModel      = "rm"
            fileprivate static let requirerSimNetworkName   = "rsn"
            fileprivate static let requirerSimCountryIso    = "rsc"
            
            fileprivate static let jsonContentTypeHeaderValue   = "application/json"
            
            //@available(*, unavailable) private init() { }
        }
    }
}

internal extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}




internal extension NSObject {
    var requestedValues: [String: Any]? {
        get { return value(forKeyPath: "requestedValues") as? [String: Any] }
        set { setValue(newValue, forKeyPath: "requestedValues") }
    }
    func value(forKey key: String, withFilterType filterType: String) -> NSObject? {
        return (value(forKeyPath: key) as? [NSObject])?.first { $0.value(forKeyPath: "filterType") as? String == filterType }
    }
}

internal extension UIView {
    func subview(of classType: AnyClass?) -> UIView? {
        return subviews.first { type(of: $0) == classType }
    }
}

private extension Dictionary {
    func percentEncoded() -> Data? {
        map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

private extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed: CharacterSet = .urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
