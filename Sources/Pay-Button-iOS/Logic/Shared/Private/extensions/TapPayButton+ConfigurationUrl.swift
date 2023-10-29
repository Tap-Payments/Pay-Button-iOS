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
        if self.getPayButtonSDKKey().contains("test") {
            return """
-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC8AX++RtxPZFtns4XzXFlDIxPB
h0umN4qRXZaKDIlb6a3MknaB7psJWmf2l+e4Cfh9b5tey/+rZqpQ065eXTZfGCAu
BLt+fYLQBhLfjRpk8S6hlIzc1Kdjg65uqzMwcTd0p7I4KLwHk1I0oXzuEu53fU1L
SZhWp4Mnd6wjVgXAsQIDAQAB
-----END PUBLIC KEY-----
"""
        }else{
            return """
-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC9hSRms7Ir1HmzdZxGXFYgmpi3
ez7VBFje0f8wwrxYS9oVoBtN4iAt0DOs3DbeuqtueI31wtpFVUMGg8W7R0SbtkZd
GzszQNqt/wyqxpDC9q+97XdXwkWQFA72s76ud7eMXQlsWKsvgwhY+Ywzt0KlpNC3
Hj+N6UWFOYK98Xi+sQIDAQAB
-----END PUBLIC KEY-----
"""
        }
    }
}
