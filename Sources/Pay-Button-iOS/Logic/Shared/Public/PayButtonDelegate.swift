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
    /// Will be fired by the card based buttons (click to pay) whenever the rendered form changes its size.
    /// The button resizes itself, implement this only if your layout pins the button to a fixed height
    /// - Parameter height: The new height in points
    @objc optional func onHeightChange(height: Double)
    /// Will be fired by the card based buttons (click to pay) once the brand of the typed card is identified
    /// - Parameter data: json data describing the identified card
    @objc optional func onBinIdentification(data: String)
    /// Will be fired when the customer asks to scan a card. Present your card scanner from here
    @objc optional func onScannerClick()
    /// Will be fired when the customer asks to read a card over NFC. Start your NFC reader from here
    @objc optional func onNfcClick()
    /// Will be fired by the card form when the customer has to be authenticated on a 3ds page
    /// - Parameter data: json data describing the 3ds page to be displayed
    @objc optional func onThreeDSRedirect(data: String)

}
