//
//  File.swift
//  
//
//  Created by Osama Rabie on 26/10/2023.
//

import Foundation

/// Defines which type of buttons to be displayed
@objc public enum PayButtonTypeEnum:Int, CaseIterable {
    /// The button will work to show payment in form of BenefitPay
    case BenefitPay
    /// The button will work to show payment in form of Knet
    case Knet
    /// The button will work to show payment in form of Benefit
    case Benefit
    /// The button will work to show payment in form of Fawry
    case Fawry
    /// The button will work to show payment in form of paypal
    case Paypal
    /// The button will work to show payment in form of tabby
    case Tabby
    /// The button will work to show payment in form of google pay
    case GooglePay
    /// The button will work to show payment in form of careem pay
    case CareemPay
    /// The button will work to show payment in form of  card
    case Card
    /// The button will work to show payment in form of ApplePay
    case ApplePay
    
    /// A string representation of the payment type
    public func toString() -> String {
        switch self {
        case .BenefitPay:
            return "BENEFITPAY"
        case .Knet:
            return "KNET"
        case .Benefit:
            return "BENEFIT"
        case .Fawry:
            return "FAWRY"
        case .Paypal:
            return "PAYPAL"
        case .Tabby:
            return "TABBY"
        case .GooglePay:
            return "GOOGLEPAY"
        case .CareemPay:
            return "CAREEMPAY"
        case .Card:
            return "CARD"
        case .ApplePay:
            return "APPLEPAY"
        }
    }
    
    /// Will define the base url for the payment type
    internal func baseUrl() -> String {
        switch self {
        case .BenefitPay:
            return "https://button.dev.tap.company/wrapper/benefitpay?configurations="
        case .Knet:
            return "https://button.dev.tap.company/wrapper/knet?configurations="
        case .Benefit:
            return "https://button.dev.tap.company/wrapper/benefit?configurations="
        case .Fawry:
            return "https://button.dev.tap.company/wrapper/fawry?configurations="
        case .Paypal:
            return "https://button.dev.tap.company/wrapper/paypal?configurations="
        case .Tabby:
            return "https://button.dev.tap.company/wrapper/tabby?configurations="
        case .GooglePay:
            return "https://button.dev.tap.company/wrapper/googlepay?configurations="
        case .CareemPay:
            return "https://button.dev.tap.company/wrapper/careempay?configurations="
        case .Card:
            return "https://button.dev.tap.company/wrapper/card?configurations="
        case .ApplePay:
            return "https://button.dev.tap.company/wrapper/applepay?configurations="
        }
    }
    
    /// Will define the scheme will be used by the original web sdk to communicate with the native view
    internal func webSdkScheme() -> String {
        switch self {
        case .BenefitPay:
            return "tapbenefitpaywebsdk://"
        case .Knet:
            return "tapknetwebsdk://"
        case .Benefit:
            return "tapbenefitwebsdk://"
        case .Fawry:
            return "tapfawrywebsdk://"
        case .Paypal:
            return "tappaypalwebsdk://"
        case .Tabby:
            return "taptabbywebsdk://"
        case .GooglePay:
            return "tapgooglepaywebsdk://"
        case .CareemPay:
            return "tapcareempaywebsdk://"
        case .Card:
            return "tapcardwebsdk://"
        case .ApplePay:
            return "tapapplepaywebsdk://"
        }
    }
    
    /// The string that we will use to tell the backend which url it should redirect to upin finishing a redirection based payment
    internal func tapRedirectionSchemeUrl() -> String {
        return "tapredirectionwebsdk://"
    }
}
