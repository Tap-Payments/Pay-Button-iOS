//
//  PayButtonIntent.swift
//
//
//  Created by Osama Rabie on 26/10/2023.
//

import Foundation

/// Interface to create an intent out of an intent configuration object .. the same flow the web pay button follows
@objcMembers public class PayButtonIntent: NSObject {

    /// The domain this integration reports as its `mdn`. The backend rejects the payment with
    /// `7022 MDN validation failed` unless the value is registered against the used public key.
    /// Leave it unset to report the app's bundle identifier, which is what a mobile integration should register.
    /// Set it to the registered web domain, the way the web pay button reports its page origin, when the
    /// bundle identifier has not been registered yet.
    public static var domain: String? {
        get { UrlBasedUtils.mdnDomain }
        set { UrlBasedUtils.mdnDomain = newValue }
    }

    ///  Creates an intent out of the passed intent configuration object.
    ///  The call is authenticated with the merchant's public key, so no secret key has to live inside the app.
    ///  - Parameter config: The intent configuration object. The same payload the web sdk passes as the intent object
    ///  - Parameter publicKey: The Tap public key for you as a merchant pk_.....
    ///  - Parameter completion: Called on the main thread with the created intent, or with the error that stopped it
    @objc public static func create(config: [String : Any], publicKey: String, completion: @escaping (_ intent:[String:Any]?, _ error:String?) -> Void) {
        // We will first need to try to load the latest base url from the CDN to make sure our backend doesn't want us to look somewhere else
        UrlBasedUtils.loadCDNConfiguration {
            DispatchQueue.main.async {
                // The encryption key we sign the headers with is derived from the passed public key
                UrlBasedUtils.publicKey = publicKey
                do {
                    try UrlBasedUtils.createIntent(from: config, with: UrlBasedUtils.generateSDKINFO(for: publicKey)) { response, error in
                        DispatchQueue.main.async {
                            completion(response, error)
                        }
                    }
                } catch {
                    completion(nil, error.localizedDescription)
                }
            }
        }
    }
}
