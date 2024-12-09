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
    //MARK: - Generate tap card sdk url methods
    
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
    
    /// Generates the mdn & the application required headers
    /// - Parameter headersEncryptionPublicKey: The encryption key to be used
    static func generateApplicationHeader(headersEncryptionPublicKey:String) -> [String:String] {
        return [
            Constants.HTTPHeaderKey.application: applicationHeaderValue(headersEncryptionPublicKey: headersEncryptionPublicKey),
            Constants.HTTPHeaderKey.mdn: Crypter.encrypt(TapApplicationPlistInfo.shared.bundleIdentifier ?? "", using: headersEncryptionPublicKey) ?? ""
        ]
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
        let deviceNameFiltered =  deviceName.tap_byRemovingAllCharactersExcept("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ123456789")
        let deviceType = UIDevice.current.model
        let deviceModel = UIDevice.current.localizedModel
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
            Constants.HTTPHeaderValueKey.requirerSimCountryIso: Crypter.encrypt(simCountryISO ?? "", using: headersEncryptionPublicKey) ?? ""
        ]
        
        return result
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
            fileprivate static let deviceID                 = "device_id"
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
