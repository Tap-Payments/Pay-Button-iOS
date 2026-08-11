//
//  PayButtonIntent.swift
//
//
//  Created by Osama Rabie on 26/10/2023.
//

import Foundation

/// Interface to create an intent out of an intent configuration object .. the same flow the web pay button follows
@objcMembers public class PayButtonIntent: NSObject {

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
