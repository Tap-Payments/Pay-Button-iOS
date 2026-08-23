//
//  File.swift
//  
//
//  Created by Osama Rabie on 26/10/2023.
//

import Foundation

/// Defines which type of buttons to be displayed
///
/// BenefitPay and CareemPay are commented out for now. The raw values are written out
/// explicitly so the remaining cases keep the numbers they have always had .. they are part of the
/// objc facing api, and letting them shift would silently remap an integrator's stored values
@objc public enum PayButtonTypeEnum:Int, CaseIterable {
    /// The button will work to show payment in form of BenefitPay
    //case BenefitPay = 0
    /// The button will work to show payment in form of Knet
    case Knet = 1
    /// The button will work to show payment in form of Benefit
    case Benefit = 2
    /// The button will work to show payment in form of Fawry
    case Fawry = 3
    /// The button will work to show payment in form of paypal
    case Paypal = 4
    /// The button will work to show payment in form of careem pay
    //case CareemPay = 5
    /// The button will work to show payment in form of tabby
    case Tabby = 6
    /// The button will work to show payment in form of google pay
    case GooglePay = 7
    /// The button will work to show payment in form of apple pay
    case ApplePay = 8
    /// The button will work to show payment in form of DEEMA
    case DEEMA = 9
    /// The button will work to show payment in form of click to pay.
    /// Appended last on purpose, the raw values of the cases above are part of the objc facing api
    case Click2Pay = 10
    /// The button will work to show payment in form of a card form
    case Card = 11
    /// The button will work to show payment in form of TAMARA.
    /// Appended last on purpose, the raw values of the cases above are part of the objc facing api
    case TAMARA = 12
    /// The button will work to show payment in form of QPAY.
    /// Appended last on purpose, the raw values of the cases above are part of the objc facing api
    case QPAY = 13

    /// A string representation of the payment type
    public func toString() -> String {
        switch self {
        //case .BenefitPay:
        //    return "BENEFITPAY"
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
        //case .CareemPay:
        //    return "CAREEMPAY"
        case .DEEMA:
            return "DEEMA"
        case .Click2Pay:
            return "CLICK2PAY"
        case .Card:
            return "CARD"
        case .TAMARA:
            return "TAMARA"
        case .QPAY:
            return "QPAY"
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

    /// The scheme the card based buttons (click to pay) use to fire their own events on top of the shared ones
    internal func cardWebSdkScheme() -> String {
        return "tapCardWebSDK://"
    }
}
