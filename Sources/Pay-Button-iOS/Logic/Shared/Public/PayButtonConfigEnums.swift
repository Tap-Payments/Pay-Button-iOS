//
//  PayButtonConfigEnums.swift
//
//
//  Created by Osama Rabie on 26/10/2023.
//

import Foundation

/// The values the web pay button accepts inside the intent configuration.
///
/// Ported from the web sdk enums so the app sends exactly the strings the web sdk sends.
/// They are nested inside this namespace on purpose, `Locale` and `Environment` are taken by
/// Foundation and SwiftUI and shadowing them for every integrator would be rude.
///
/// Usage: `PayButtonConfig.Edges.circular.rawValue`
public enum PayButtonConfig {

    /// `config.interface.locale`
    public enum Locale: String, CaseIterable {
        case en, ar, dynamic
    }

    /// `config.interface.direction` and `config.interface.card_direction`
    public enum Direction: String, CaseIterable {
        case ltr, rtl, dynamic
    }

    /// `config.interface.theme`
    public enum ThemeMode: String, CaseIterable {
        case dark, light, dynamic
    }

    /// `config.interface.edges`
    public enum Edges: String, CaseIterable {
        case straight, curved, circular
    }

    /// `config.interface.color_style`
    public enum ColorStyle: String, CaseIterable {
        case colored, monochrome
    }

    /// `config.interface.user_experience`
    public enum UserExperience: String, CaseIterable {
        case popup, page
    }

    /// The server the sdk talks to
    public enum Environment: String, CaseIterable {
        case live, development
    }

    /// `scope`
    public enum Scope: String, CaseIterable {
        case charge            = "CHARGE"
        case authorize         = "AUTHORIZE"
        case token             = "TOKEN"
        case applePayToken     = "APPLE_PAY_TOKEN"
        case googlePayToken    = "GOOGLE_PAY_TOKEN"
        case samsungPayToken   = "SAMSUNG_PAY_TOKEN"
        case clickToPayToken   = "CLICK_TO_PAY_TOKEN"
    }

    /// `config.acceptance.supported_payment_types`
    public enum AcceptancePaymentType: String, CaseIterable {
        case device      = "DEVICE"
        case card        = "CARD"
        case bnpl        = "BNPL"
        case mobile      = "MOBILE"
        case wallet      = "WALLET"
        case webRedirect = "WEB / REDIRECT"
    }

    /// `config.acceptance.supported_payment_methods`.
    /// Careful, not every value here renders a button on mobile. `PayButtonTypeEnum` is the
    /// subset the pay button page actually has a mobile screen for.
    public enum AcceptancePaymentMethod: String, CaseIterable {
        case visa        = "VISA"
        case mastercard  = "MASTERCARD"
        case amex        = "AMEX"
        case knet        = "KNET"
        case benefit     = "BENEFIT"
        case paypal      = "PAYPAL"
        case applePay    = "APPLE_PAY"
        case googlePay   = "GOOGLE_PAY"
        case benefitPay  = "BENEFIT_PAY"
        case careemPay   = "CAREEM_PAY"
        case samsungPay  = "SAMSUNG_PAY"
        case stcPay      = "STC_PAY"
        case click2Pay   = "CLICK2PAY"
        case fawry       = "FAWRY"
        case qpay        = "QPAY"
        case tabby       = "TABBY"
        case deema       = "DEEMA"
        case tamara      = "TAMARA"
        case card        = "CARD"
    }

    /// The theme flavours the card based buttons render
    public enum FullThemeMode: String, CaseIterable {
        case dark        = "dark"
        case light       = "light"
        case lightMono   = "light_mono"
        case darkColored = "dark_colored"
    }

    /// The `response.code` values a charge comes back with
    public enum ChargeCode: String, CaseIterable {
        case success    = "000"
        case authorized = "001"
        case inProgress = "200"
        case initiated  = "100"
    }

    /// The unit used when scheduling an authorize capture
    public enum TimeType: String, CaseIterable {
        case milliSecond = "MILLI_SECOND"
        case second      = "SECOND"
        case minute      = "MINUTE"
        case hour        = "HOUR"
        case day         = "DAY"
        case week        = "WEEK"
        case month       = "MONTH"
        case year        = "YEAR"
    }

    // MARK: - Acceptance value sets
    // Not part of the web sdk's exported enums, taken from the values the web demo sends
    // so every acceptance field can be picked from a list instead of typed by hand.

    /// `config.acceptance.supported_regions`
    public enum AcceptanceRegion: String, CaseIterable {
        case local    = "LOCAL"
        case regional = "REGIONAL"
        case global   = "GLOBAL"
    }

    /// `config.acceptance.supported_currencies` and `order.currency`
    public enum Currency: String, CaseIterable {
        case kwd = "KWD"
        case sar = "SAR"
        case aed = "AED"
        case omr = "OMR"
        case qar = "QAR"
        case bhd = "BHD"
        case egp = "EGP"
        case gbp = "GBP"
        case usd = "USD"
        case eur = "EUR"
    }

    /// `config.acceptance.supported_schemes`
    public enum Scheme: String, CaseIterable {
        case mada        = "MADA"
        case omannet     = "OMANNET"
        case visa        = "VISA"
        case mastercard  = "MASTERCARD"
        case amex        = "AMEX"
        case benefitCard = "BENEFIT_CARD"
        case meeza       = "MEEZA"
    }

    /// `config.acceptance.supported_fund_source`
    public enum FundSource: String, CaseIterable {
        case debit  = "DEBIT"
        case credit = "CREDIT"
    }

    /// `config.acceptance.supported_payment_authentications`
    public enum PaymentAuthentication: String, CaseIterable {
        case threeDS = "3DS"
        case emv     = "EMV"
        case passkey = "PASSKEY"
    }

    /// `config.acceptance.supported_payment_flows`
    public enum PaymentFlow: String, CaseIterable {
        case popup = "POPUP"
        case page  = "PAGE"
    }

    /// The source a charge is created against
    public enum SourceId: String, CaseIterable {
        case all         = "SRC_ALL"
        case card        = "SRC_CARD"
        case authorizeId = "AUTHORIZE_ID"
        case tokenId     = "TOKEN_ID"
        case stcPay      = "SRC_SA.STCPAY"
        case googlePay   = "SRC_GOOGLE_PAY"
        case applePay    = "SRC_APPLE_PAY"
        case qpay        = "STC_QA.QPAY"
        case benefitPay  = "SRC_BENEFITPAY"
        case benefit     = "SRC_BH.BENEFIT"
        case fawry       = "SRC_EG.FAWRY"
        case knet        = "SRC_KW.KNET"
        case mada        = "SRC_SA.MADA"
    }
}

public extension PayButtonConfig.Scope {

    /// The scopes every payment method accepts
    static var shared: [PayButtonConfig.Scope] { [.charge, .authorize, .token] }

    /// The scopes that are valid for a given payment method.
    ///
    /// The token scopes are minted by one specific wallet, so `APPLE_PAY_TOKEN` only means
    /// something when the button is Apple Pay, `GOOGLE_PAY_TOKEN` only for Google Pay, and so on.
    /// Asking for a token scope the selected method can not mint is rejected by the backend.
    /// - Parameter paymentMethod: The value put in `config.acceptance.supported_payment_methods`
    static func allowed(for paymentMethod: String?) -> [PayButtonConfig.Scope] {
        guard let paymentMethod = paymentMethod?.uppercased() else { return shared }
        switch paymentMethod {
        case PayButtonConfig.AcceptancePaymentMethod.applePay.rawValue:
            return shared + [.applePayToken]
        case PayButtonConfig.AcceptancePaymentMethod.googlePay.rawValue:
            return shared + [.googlePayToken]
        case PayButtonConfig.AcceptancePaymentMethod.samsungPay.rawValue:
            return shared + [.samsungPayToken]
        case PayButtonConfig.AcceptancePaymentMethod.click2Pay.rawValue:
            return shared + [.clickToPayToken]
        default:
            return shared
        }
    }
}

public extension CaseIterable where Self: RawRepresentable, Self.RawValue == String {
    /// The raw values of every case, ready to be handed to a picker
    static var allRawValues: [String] {
        allCases.map { $0.rawValue }
    }
}
