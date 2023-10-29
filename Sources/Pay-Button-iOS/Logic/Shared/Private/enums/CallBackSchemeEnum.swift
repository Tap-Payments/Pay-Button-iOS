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
    
}
