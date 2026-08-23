//
//  PayButtonSdk+SdkEvents.swift
//  Pay-Button-iOS
//
//  The events the button web sdk fires over its own scheme, and what each one means for the
//  merchant's delegate.
//

import Foundation
import UIKit
import WebKit
import SharedDataModels_iOS

/// Handles the events the button web sdk fires
extension PayButtonSdk {

    /// Will handle & starte the redirection process when called
    /// - Parameter data: The data string fetched from the url parameter
    internal func handleOnChargeCreated(data:String) {
        // let us make sure we have the data we need to start such a process
        guard let redirection:Redirection = try? Redirection(data),
              let _:String = redirection.url,
              let chargeID:String = redirection.id else {
            // This means, there is such an error from the integration with web sdk
            delegate?.onError?(data: "Failed to start redirection process")
            return
        }
        // Let us pass the charge created id for the delegae
        self.delegate?.onChargeCreated?(data: chargeID)
        // Let us see if we have to redirect or now
        if !(redirection.stopRedirection ?? false) {
            showRedirectionView(for: redirection)
        }
    }

    /// The payment went through. The merchant hears about it, then the button goes back to how it
    /// started .. this payment is over and nothing of it belongs to the next one
    func handleOnSuccess(url:URL) {
        self.delegate?.onSuccess?(data: tap_extractDataFromUrl(url, for: "data", shouldBase64Decode: true))
//        reset()
    }

    /// The payer backed out. The web sdk is told first, since reloading the page takes the window
    /// that call is made on with it
    func handleOnCancel() {
        self.delegate?.onCanceled?()
        self.webView.evaluateJavaScript("window.cancel()") { [weak self] _, _ in
//            self?.reset()
        }
    }

    /// The payment failed. Same as a success as far as the button is concerned, it is over and the
    /// next one starts on a clean page
    func handleOnError(data:String) {
        self.delegate?.onError?(data:data)
//        reset()
    }
}
