//
//  TapRedirection+CardWebSDK.swift
//
//
//  Created by Osama Rabie on 26/10/2023.
//

import Foundation
import UIKit
import WebKit
import SharedDataModels_iOS

/// The card based buttons, CARD and CLICK2PAY, render the card web sdk inside the button page.
/// On top of the shared `tapbuttonsdk://` events it fires its own over `tapCardWebSDK://`,
/// which is what this file deals with. Same contract Card-iOS implements, it is the same web sdk.
extension RedirectionPayButton {

    /// Handles the events fired by the card based buttons over the `tapCardWebSDK://` scheme
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
            break
        case _ where url.absoluteString.contains(CallBackSchemeEnum.onNfcClick.rawValue):
            delegate?.onNfcClick?()
            break
        case _ where url.absoluteString.contains(CallBackSchemeEnum.on3dsRedirect.rawValue):
            handleCardRedirection(data: tap_extractDataFromUrl(url, for: "data", shouldBase64Decode: true))
            break
        default:
            break
        }
    }

    /// Starts the 3ds authentication the card form asked for.
    /// Ported from Card-iOS: load `threeDsUrl`, watch the loaded pages for `keyword`,
    /// then hand the whole url back to the card sdk.
    /// - Parameter data: The decoded json the card sdk sent with `on3dsRedirect`
    internal func handleCardRedirection(data:String) {
        // Let the merchant see it either way, some integrators drive their own ui from it
        delegate?.onThreeDSRedirect?(data: data)

        // Make sure we have what it takes to run the process
        guard let cardRedirection:CardRedirection = try? CardRedirection(data),
              let threeDsUrl:String = cardRedirection.threeDsUrl, !threeDsUrl.isEmpty,
              let _:String = cardRedirection.redirectUrl else {
            delegate?.onError?(data: "{\"error\":\"Failed to start authentication process\"}")
            return
        }

        // An ACS that asks for a passkey can not run in a web view, it has no navigator.credentials.
        // Card-iOS hands those over to the system browser, we do not have that path yet so say so
        // rather than showing a page that can never complete
        if threeDsUrl.lowercased().contains("passkey") {
            delegate?.onError?(data: "{\"error\":\"This authentication needs a passkey, which a web view can not serve\"}")
            return
        }

        threeDsView = .init()
        threeDsView?.isModalInPresentation = true
        threeDsView?.redirectionData = .init(url: threeDsUrl, id: nil, powered: cardRedirection.powered, stopRedirection: false)
        // Watch for the card sdk's own keyword instead of the shared redirection one
        threeDsView?.cardRedirectionKeyword = cardRedirection.keyword
        threeDsView?.selectedLocale = currentlyLoadedConfigurations?.getButtonLocale() ?? "en"
        threeDsView?.poweredByTapView.isHidden = !(cardRedirection.powered ?? true)
        threeDsView?.threeDSCanceled = {
            self.threeDsView?.dismiss(animated: true, completion: {
                self.handleCardAuthenticationCanceled()
            })
        }
        threeDsView?.redirectionReached = { redirectionUrl in
            self.threeDsView?.dismiss(animated: true) {
                DispatchQueue.main.async {
                    self.passCardAuthenticationToSDK(redirectionUrl: redirectionUrl)
                }
            }
        }
        threeDsView?.idleForWhile = {
            self.threeDsView?.idleForWhile = {}
            DispatchQueue.main.async {
                UIApplication.shared.topViewController()!.present(self.threeDsView!, animated: true)
            }
        }
        threeDsView?.startLoading()
    }

    /// Tells the card form the payer finished authenticating.
    /// The button page forwards this to the card iframe on its own, the same way Card-iOS relies on it.
    /// - Parameter redirectionUrl: The whole url the 3ds page landed on
    internal func passCardAuthenticationToSDK(redirectionUrl:String) {
        webView.evaluateJavaScript("window.loadAuthentication('\(redirectionUrl)')")
    }

    /// The payer backed out of the 3ds page
    internal func handleCardAuthenticationCanceled() {
        delegate?.onCanceled?()
        webView.evaluateJavaScript("window.cancel()")
    }
}
