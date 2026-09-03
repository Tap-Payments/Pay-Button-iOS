//
//  File.swift
//  
//
//  Created by Osama Rabie on 26/10/2023.
//

import Foundation

/// An enum with all possible values expected as callbacks from the web pay button
internal enum CallBackSchemeEnum:String {
    /// Will be called only when the button is rendered
    case onReady
    /// Will be called when the customer clicked the button
    case onClick
    /// Wull be called upon a successful charge
    case onSuccess
    /// An error happened with the charge
    case onError
    /// The customer canceled the payment
    case onCancel
    /// An order has been created
    case onOrderCreated
    /// The charge has been created
    case onChargeCreated
    /// We need to close Google pay popup
    case onClosePopup
    /// The card based button (click to pay) resized itself and wants the native view to follow
    case onHeightChange
    /// The card based button identified the brand of the typed card
    case onBinIdentification
    /// The customer asked to scan a card
    case onScannerClick
    /// The customer asked to read a card over NFC
    case onNfcClick
    /// The card form needs a 3ds page to be displayed to authenticate the customer
    case on3dsRedirect
    /// A passkey authentication finished and the return page is handing the answer back
    case onPasskeyRedirect
    /// Apple Pay asks us to validate the merchant before it will show the sheet's payment methods
    case onMerchantValidation
    /// The payer picked a different Apple Pay shipping method
    case onShippingMethodSelected
    /// The payer picked or edited their Apple Pay shipping contact
    case onShippingContactSelected
    /// The payer picked a different card inside the Apple Pay sheet
    case onPaymentMethodSelected
    /// The payer typed or cleared a coupon code
    case onCouponChanged

}
