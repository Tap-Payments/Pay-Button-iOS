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
    
    /// A string representation of the payment type
    public func toString() -> String {
        switch self {
        case .BenefitPay:
            return "BENEFITPAY"
        case .Knet:
            return "KNET"
        case .Benefit:
            return "BENEFIT"
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
        }
    }
    
    /// The string that we will use to tell the backend which url it should redirect to upin finishing a redirection based payment
    internal func tapRedirectionSchemeUrl() -> String {
        return "tapredirectionwebsdk://"
    }
}
