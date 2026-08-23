//
//  PayButtonSdk+CardEvents.swift
//  Pay-Button-iOS
//
//  The events the card form fires over `tapCardWebSDK://`, ex the form resizing itself or a card
//  being identified. Its own scheme, so its own handler.
//

import Foundation
import UIKit
import WebKit
import SharedDataModels_iOS

/// Handles the events the card form fires
extension PayButtonSdk {

    /// Handles the events fired by the card based buttons (click to pay) over the `tapCardWebSDK://` scheme
    /// - Parameter url: The url the web sdk tried to navigate to
    internal func handleCardWebSdkCallback(url:URL) {
        switch url.absoluteString {
        case _ where url.absoluteString.contains(CallBackSchemeEnum.onHeightChange.rawValue):
            // The height comes as a plain number, not as a base64 encoded json
            let reportedHeight:String = tap_extractDataFromUrl(url, for: "data", shouldBase64Decode: false)
            guard let height:Double = Double(reportedHeight) else { break }
            // Resize ourselves. The reports come in bursts, so updateHeight settles them and
            // notifies the delegate once, rather than making the merchant animate on every report
            updateHeight(to: CGFloat(height))
            break
        case _ where url.absoluteString.contains(CallBackSchemeEnum.onBinIdentification.rawValue):
            delegate?.onBinIdentification?(data: tap_extractDataFromUrl(url, for: "data", shouldBase64Decode: true))
            break
        case _ where url.absoluteString.contains(CallBackSchemeEnum.onScannerClick.rawValue):
            delegate?.onScannerClick?()
            // Ported from Card-iOS .. the sdk answers this itself rather than leaving the merchant
            // to open a camera and find its way back into the form
            scanCard()
            break
        case _ where url.absoluteString.contains(CallBackSchemeEnum.onNfcClick.rawValue):
            delegate?.onNfcClick?()
            break
        case _ where url.absoluteString.contains(CallBackSchemeEnum.onPasskeyRedirect.rawValue):
            // The browser normally takes this one, the session claims the scheme and never lets it
            // reach the web view. It lands here when the page bounces to it from inside the form
            NSLog("PayButton: a passkey callback arrived in the web view, \(url.absoluteString)")
            threeDSPasskeySession?.handleCallback(url: url)
            break
        case _ where url.absoluteString.contains(CallBackSchemeEnum.on3dsRedirect.rawValue):
            handleCardRedirection(data: tap_extractDataFromUrl(url, for: "data", shouldBase64Decode: true))
            break
        default:
            break
        }
    }
}
