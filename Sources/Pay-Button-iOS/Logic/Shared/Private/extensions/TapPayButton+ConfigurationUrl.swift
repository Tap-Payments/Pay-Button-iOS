//
//  TapCard+ConfigurationUrl.swift
//  TapCardCheckOutKit
//
//  Created by Osama Rabie on 13/09/2023.
//

import Foundation
import SharedDataModels_iOS

internal extension URL {
    
    /// Fetch the localisation selected by the parent app for the card sdk
    func getButtonLocale() -> String {
        /// Let us make sure we can get a correctly passed locale from the configurations
        // Is it a correct json
        let configurationsString:String = tap_extractDataFromUrl(self,for: "configurations", shouldBase64Decode: false).lowercased()
        if let configurationData = configurationsString.data(using: .utf8),
           let configurationDictionary: [String:Any] = try? JSONSerialization.jsonObject(with: configurationData, options: []) as? [String: Any],
           // Did the merchant pass an interface
           let interfaceDictionary:[String:Any] = configurationDictionary["interface"] as? [String:Any],
           // Did the merchant pass a locale
           let selectedLocale:String = interfaceDictionary["locale"] as? String {
            return selectedLocale.lowercased()
        }
        // The default case
        return "en"
    }
    
    
    /// Fetch the localisation selected by the parent app for the card sdk
    func getButtonTheme() -> String {
        /// Let us make sure we can get a correctly passed locale from the configurations
        // Is it a correct json
        let configurationsString:String = tap_extractDataFromUrl(self,for: "configurations", shouldBase64Decode: false).lowercased()
        if let configurationData = configurationsString.data(using: .utf8),
           let configurationDictionary: [String:Any] = try? JSONSerialization.jsonObject(with: configurationData, options: []) as? [String: Any],
           // Did the merchant pass an interface
           let interfaceDictionary:[String:Any] = configurationDictionary["interface"] as? [String:Any],
           // Did the merchant pass a locale
           let selectedTheme:String = interfaceDictionary["theme"] as? String {
            return selectedTheme.lowercased()
        }
        // The default case
        return "light"
    }
    
    
    /// Fetch the localisation selected by the parent app for the card sdk
    func getButtonEdges() -> String {
        /// Let us make sure we can get a correctly passed locale from the configurations
        // Is it a correct json
        let configurationsString:String = tap_extractDataFromUrl(self,for: "configurations", shouldBase64Decode: false).lowercased()
        if let configurationData = configurationsString.data(using: .utf8),
           let configurationDictionary: [String:Any] = try? JSONSerialization.jsonObject(with: configurationData, options: []) as? [String: Any],
           // Did the merchant pass an interface
           let interfaceDictionary:[String:Any] = configurationDictionary["interface"] as? [String:Any],
           // Did the merchant pass a locale
           let selectedEdges:String = interfaceDictionary["edges"] as? String {
            return selectedEdges.lowercased()
        }
        // The default case
        return "curved"
    }
    
    
    /// Fetch the localisation selected by the parent app for the card sdk
    func getPayButtonSDKKey() -> String {
        /// Let us make sure we can get a correctly passed locale from the configurations
        // Is it a correct json
        let configurationsString:String = tap_extractDataFromUrl(self,for: "configurations", shouldBase64Decode: false)
        if let configurationData = configurationsString.data(using: .utf8),
           let configurationDictionary: [String:Any] = try? JSONSerialization.jsonObject(with: configurationData, options: []) as? [String: Any],
           // Did the merchant pass an interface
           let interfaceDictionary:[String:Any] = configurationDictionary["operator"] as? [String:Any],
           // Did the merchant pass a locale
           let selectedKey:String = interfaceDictionary["publicKey"] as? String {
            return selectedKey
        }
        // The default case
        return "pk_test_YhUjg9PNT8oDlKJ1aE2fMRz7"
    }
    
    /// comutes the encryption key for the respected server
    func headersEncryptionPublicKey() -> String {
        // Same key the intent calls sign their headers with, so the mdn we report stays one single value
        return UrlBasedUtils.publicEncryptionKey
    }
}


internal extension Dictionary {
    
    /// Fetch the localisation selected by the parent app for the card sdk
    func getButtonLocale() -> String {
        /// Let us make sure we can get a correctly passed locale from the configurations
        if // Did the merchant pass an interface
           let interfaceDictionary:[String:Any] = ["interface"] as? [String:Any],
           // Did the merchant pass a locale
           let selectedLocale:String = interfaceDictionary["locale"] as? String {
            return selectedLocale.lowercased()
        }
        // The default case
        return "en"
    }
    
    
    /// Fetch the localisation selected by the parent app for the card sdk
    func getButtonTheme() -> String {
        /// Let us make sure we can get a correctly passed locale from the configurations
         if let interfaceDictionary:[String:Any] = ["interface"] as? [String:Any],
           // Did the merchant pass a locale
           let selectedTheme:String = interfaceDictionary["theme"] as? String {
            return selectedTheme.lowercased()
        }
        // The default case
        return "light"
    }
    
    
    /// Fetch the localisation selected by the parent app for the card sdk
    func getButtonEdges() -> String {
        /// Let us make sure we can get a correctly passed locale from the configurations
        if // Did the merchant pass an interface
           let interfaceDictionary:[String:Any] = ["interface"] as? [String:Any],
           // Did the merchant pass a locale
           let selectedEdges:String = interfaceDictionary["edges"] as? String {
            return selectedEdges.lowercased()
        }
        // The default case
        return "curved"
    }
    
    
    /// Fetch the localisation selected by the parent app for the card sdk
    func getPayButtonSDKKey() -> String {
        /// Let us make sure we can get a correctly passed locale from the configurations
        if let interfaceDictionary:[String:Any] = ["operator"] as? [String:Any],
           // Did the merchant pass a locale
           let selectedKey:String = interfaceDictionary["publicKey"] as? String {
            return selectedKey
        }
        // The default case
        return "pk_test_YhUjg9PNT8oDlKJ1aE2fMRz7"
    }
    
    /// comutes the encryption key for the respected server
    func headersEncryptionPublicKey() -> String {
        // Same key the intent calls sign their headers with, so the mdn we report stays one single value
        return UrlBasedUtils.publicEncryptionKey
    }
}


internal extension String {

    /// Converts a base64 string to the original
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    /// Converts original string to base64 one
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }

}
