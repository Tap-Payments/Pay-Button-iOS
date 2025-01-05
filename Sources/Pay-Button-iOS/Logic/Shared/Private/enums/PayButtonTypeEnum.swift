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
    /// The button will work to show payment in form of careem pay
    case CareemPay
    /// The button will work to show payment in form of tabby
    case Tabby
    /// The button will work to show payment in form of google pay
    case GooglePay
    /// The button will work to show payment in form of apple pay
    case ApplePay
    /// The button will work to show payment in form of DEEMA
    case DEEMA
    
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
            return "GOOGLE_PAY"
        case .ApplePay:
            return "APPLE_PAY"
        case .CareemPay:
            return "CAREEMPAY"
        case .DEEMA:
            return "DEEMA"
        }
    }
    
    /// Will define the scheme will be used by the original web sdk to communicate with the native view
    internal func webSdkScheme() -> String {
        return "tapbuttonsdk://"
        /*switch self {
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
        case .ApplePay:
            return "tapapplepaywebsdk://"
        case .CareemPay:
            return "tapcareempaywebsdk://"
        }*/
    }
    
    /// The string that we will use to tell the backend which url it should redirect to upin finishing a redirection based payment
    internal func tapRedirectionSchemeUrl() -> String {
        return "tapredirectionwebsdk://"
    }
}
