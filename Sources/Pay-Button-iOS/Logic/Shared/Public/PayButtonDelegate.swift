//
//  File.swift
//  
//
//  Created by Osama Rabie on 06/10/2023.
//

import Foundation

/// A protocol to allow listening to events and callbacks coming from the pay button
@objc public protocol PayButtonDelegate {
    
    /// Will be fired whenever the benefit pay button is rendered and loaded
    @objc optional func onReady()
    /// Will be fired whenever the customer clicked on the pay button. Now the button will be in loading state
    @objc optional func onClick()
    /// Will be fired whenever the customer cancels the payment. This will reload the button once again
    @objc optional func onCanceled()
    /// Will be fired whenever to indicate which card had been entered. This will only happen if the payment button is card based and the merchant didn't pass auth and token
    /// - Parameter data: includes a JSON format for the detected bin look up card
    @objc optional func onBinIdentification(data:String)
    /// Will be fired whenever there is an error related to the card connectivity or apis
    /// - Parameter data: includes a JSON format for the error description and error
    @objc optional func onError(data: String)
    /// Will be fired whenever the charge is success
    /// - Parameter data: includes a JSON format for the charge details
    @objc optional func onSuccess(data: String)
    /// Will be fired whenever the order is created. use it, if you want to retrieve its data from your backend for state manegement purposes
    /// - Parameter data: Order id.
    @objc optional func onOrderCreated(data: String)
    /// Will be fired whenever the charge is created. use it, if you want to retrieve its data from your backend for state manegement purposes
    /// - Parameter data: json data representing the charge model.
    @objc optional func onChargeCreated(data: String)
    /// - Parameter data: includes a the new required height by the sdk
    @objc optional func onHeightChange(height: Double)
    
}
