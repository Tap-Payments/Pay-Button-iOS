//
//  TapCardView+WebDelegate.swift
//  TapCardCheckOutKit
//
//  Created by Osama Rabie on 12/09/2023.
//

import Foundation
import UIKit
import WebKit
import SharedDataModels_iOS

/// An extension to take care of the notifications being sent from the web view through the url schemes
extension RedirectionPayButton:WKNavigationDelegate {
    
    
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        var action: WKNavigationActionPolicy?
        
        defer {
            decisionHandler(action ?? .allow)
        }
        
        guard let url = navigationAction.request.url else { return }
        
        // The scheme is the only part a url parser is allowed to case fold, so match it case insensitively
        let isCardWebSdkCallback:Bool = url.absoluteString.lowercased().hasPrefix(payButtonType.cardWebSdkScheme().lowercased())
        
        if url.absoluteString.hasPrefix(payButtonType.webSdkScheme()) || isCardWebSdkCallback {
            print("navigationAction", url.absoluteString)
            action = .cancel
        }else{
            print("navigationAction", url.absoluteString)
            
        }
        // Let us see if the web sdk is telling us something
        if( url.absoluteString.contains(payButtonType.webSdkScheme())) {
            switch url.absoluteString {
            case _ where url.absoluteString.contains(CallBackSchemeEnum.onError.rawValue):
                self.handleOnError(data: tap_extractDataFromUrl(url, for: "data", shouldBase64Decode: true))
                break
            case _ where url.absoluteString.contains(CallBackSchemeEnum.onOrderCreated.rawValue):
                delegate?.onOrderCreated?(data: tap_extractDataFromUrl(url, for: "data", shouldBase64Decode: false))
                break
            case _ where url.absoluteString.contains(CallBackSchemeEnum.onChargeCreated.rawValue):
                self.handleOnChargeCreated(data: tap_extractDataFromUrl(url, for: "data", shouldBase64Decode: true))
                break
            case _ where url.absoluteString.contains(CallBackSchemeEnum.onSuccess.rawValue):
                self.handleOnSuccess(url:url)
                break
            case _ where url.absoluteString.contains(CallBackSchemeEnum.onReady.rawValue):
                delegate?.onReady?()
                break
            case _ where url.absoluteString.contains(CallBackSchemeEnum.onClick.rawValue):
                delegate?.onClick?()
                break
            case _ where url.absoluteString.contains(CallBackSchemeEnum.onCancel.rawValue):
                self.delegate?.onCanceled?()
                break
            default:
                break
            }
        }else if isCardWebSdkCallback {
            // The card based buttons (click to pay) fire their own events on a separate scheme
            self.handleCardWebSdkCallback(url: url)
        }else if url.absoluteString.hasPrefix(payButtonType.tapRedirectionSchemeUrl()) {
            
        }else if RedirectionPayButton.requiresSystemBrowser(threeDsUrl: url.absoluteString),
                       threeDSAuthSession == nil {
            action = .cancel
            startFidoAuthentication(threeDsUrl: url.absoluteString,
                                    redirectUrl: lastCardRedirection?.redirectUrl)
            return
        }
    }
    
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
    
    /// Will create a redirection UIView and display it alert level on top of the current screen
    /// - Parameter for redirection: The redirection model that contains the redirection URL + the redirection finished keyword
    func showRedirectionView(for redirection:Redirection) {
        // This means we are ok to start the authentication process
        threeDsView = .init()
        threeDsView?.isModalInPresentation = true
        // Set to web view the needed urls
        /// The redirect url scheme
        threeDsView?.redirectUrl = payButtonType.tapRedirectionSchemeUrl()
        threeDsView?.redirectionData = redirection
        // Set the selected card locale for correct semantic rendering
        threeDsView?.selectedLocale = currentlyLoadedConfigurations?.getButtonLocale() ?? "en"
        // Set to web view what should it when the process is canceled by the user
        threeDsView?.threeDSCanceled = {
            // dismiss the threeds page
            self.threeDsView?.dismiss(animated: true,completion: {
                self.handleOnCancel()
            })
        }
        // Hide or show the powered by tap based on coming parameter
        threeDsView?.poweredByTapView.isHidden = !(redirection.powered ?? true)
        // Set to web view what should it when the process is completed by the user
        threeDsView?.redirectionReached = { redirectionUrl in
            self.threeDsView?.dismiss(animated: true) {
                DispatchQueue.main.async {
                    self.passRedirectionDataToSDK(rediectionUrl: redirectionUrl)
                }
            }
        }
        // Set to web view what should it do when the content is loaded in the background
        threeDsView?.idleForWhile = {
            self.threeDsView?.idleForWhile = {}
            DispatchQueue.main.async {
                UIApplication.shared.topViewController()!.present(self.threeDsView!, animated: true)
            }
        }
        // Tell it to start rendering 3ds content in background
        //SwiftEntryKit.display(entry: threeDsView, using: threeDsView.swiftEntryAttributes())
        threeDsView?.startLoading()
    }
    
    /// Starts the 3ds authentication the card form asked for.
    /// Ported from Card-iOS, the card form behind the button is the same web sdk, so the contract is
    /// the same: load `threeDsUrl`, watch the loaded pages for `keyword`, then hand the whole url back.
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
        
        // Kept so a passkey that arrives later as a plain navigation still knows the return url
        lastCardRedirection = cardRedirection
        
        // An ACS that asks for a passkey can not run in a web view, it has no navigator.credentials.
        // Hand the whole process over to the system browser instead, the same way Card-iOS does
        if RedirectionPayButton.requiresSystemBrowser(threeDsUrl: threeDsUrl) {
            startFidoAuthentication(with: cardRedirection)
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
    ///
    /// The button page wraps the card in an iframe, and its own `window.loadAuthentication` posts through
    /// the button's iframe events which need an `iframeId` the mobile url never carries. `window.CardSDK`
    /// talks to the card iframe directly, so prefer it and keep the other one as a fallback.
    /// - Parameter redirectionUrl: The whole url the 3ds page landed on
    internal func passCardAuthenticationToSDK(redirectionUrl:String) {
        // Keep the url safe to drop inside a single quoted js string
        let escapedUrl:String = redirectionUrl
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "'", with: "\\'")
        let javaScript:String = """
        (function() {
            var authenticationUrl = '\(escapedUrl)';
            if (window.CardSDK && typeof window.CardSDK.loadAuthentication === 'function') {
                window.CardSDK.loadAuthentication(authenticationUrl);
                return 'CardSDK';
            }
            if (typeof window.loadAuthentication === 'function') {
                window.loadAuthentication(authenticationUrl);
                return 'window';
            }
            return 'none';
        })()
        """
        webView.evaluateJavaScript(javaScript) { result, error in
            print("loadAuthentication handled by: \(result ?? "nil") \(error?.localizedDescription ?? "")")
        }
    }
    
    /// Decides whether the authentication has to leave the web view. An ACS url that advertises a
    /// passkey challenge can not run inside `WKWebView`, it does not expose `navigator.credentials`
    /// - Parameter threeDsUrl: The ACS page coming from the redirection details
    /// - Returns: True when the process belongs in the system browser
    internal static func requiresSystemBrowser(threeDsUrl:String?) -> Bool {
        guard let threeDsUrl:String = threeDsUrl else { return false }
        return threeDsUrl.lowercased().contains("passkey")
    }
    
    /// Runs the authentication inside the system browser, which unlike `WKWebView` can execute
    /// `navigator.credentials` and therefore serve a passkey challenge
    /// - Parameter cardRedirection: The validated redirection details
    internal func startFidoAuthentication(with cardRedirection:CardRedirection) {
        startFidoAuthentication(threeDsUrl: cardRedirection.threeDsUrl,
                                redirectUrl: cardRedirection.redirectUrl)
    }
    
    /// Runs the authentication inside the system browser
    /// - Parameter threeDsUrl: The acs page to load
    /// - Parameter redirectUrl: The https return url the callback is mapped back onto. Nil when the
    /// challenge arrived as a plain navigation and no `on3dsRedirect` announced it first
    internal func startFidoAuthentication(threeDsUrl:String?, redirectUrl:String?) {
        let authSession:ThreeDSAuthSession = .init()
        authSession.delegate = self
        threeDSAuthSession = authSession
        
        authSession.start(threeDsUrl: threeDsUrl,
                          redirectUrl: redirectUrl,
                          callback: PayButtonView.threeDSCallback,
                          ephemeral: PayButtonView.threeDSPrefersEphemeralSession,
                          in: window)
    }
    
    /// The payer backed out of the 3ds page
    internal func handleCardAuthenticationCanceled() {
        delegate?.onCanceled?()
        let javaScript:String = """
        (function() {
            if (window.CardSDK && typeof window.CardSDK.cancelAuthentication === 'function') {
                window.CardSDK.cancelAuthentication();
                return 'CardSDK';
            }
            if (typeof window.cancel === 'function') {
                window.cancel();
                return 'window';
            }
            return 'none';
        })()
        """
        webView.evaluateJavaScript(javaScript)
    }
    
    func handleOnSuccess(url:URL) {
        self.delegate?.onSuccess?(data: tap_extractDataFromUrl(url, for: "data", shouldBase64Decode: true))
        //self.openUrl(url: self.currentlyLoadedConfigurations)
    }
    
    func handleOnCancel() {
        self.delegate?.onCanceled?()
        self.webView.evaluateJavaScript("window.cancel()")
    }
    
    
    func handleOnError(data:String) {
        self.delegate?.onError?(data:data)
        //self.openUrl(url: self.currentlyLoadedConfigurations)
    }
}

/// Receives the outcome of a passkey authentication that ran in the system browser
extension RedirectionPayButton: ThreeDSAuthSessionDelegate {
    
    /// The browser came back with the return url, hand it over to the card form
    func threeDSAuthSession(_ session: ThreeDSAuthSession, didSucceedWith redirectionUrl: String) {
        threeDSAuthSession = nil
        passCardAuthenticationToSDK(redirectionUrl: redirectionUrl)
    }
    
    /// The payer dismissed the browser before finishing the authentication
    func threeDSAuthSessionDidCancel(_ session: ThreeDSAuthSession) {
        threeDSAuthSession = nil
        handleCardAuthenticationCanceled()
    }
    
    /// The process could not be completed
    func threeDSAuthSession(_ session: ThreeDSAuthSession, didFailWith error: Error) {
        threeDSAuthSession = nil
        delegate?.onError?(data: "{\"error\":\"\(error.localizedDescription)\"}")
    }
}

/// Serves the windows the card web sdk opens with `window.open`, ex the click to pay identity flow
extension RedirectionPayButton:WKUIDelegate {
    
    /// The card form asked for a new window.
    ///
    /// The web view has to be built out of the `configuration` WebKit passed us and handed back, that is what
    /// keeps the popup's `window.opener` pointing at the form. Click to pay posts the card the payer picked
    /// back through it, so building our own web view instead would leave the form waiting forever.
    /// WebKit loads the request into whatever we return, so there is nothing to load here.
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        // A window targeted at the form itself is not a popup, let it navigate in place
        guard navigationAction.targetFrame == nil else {
            webView.load(navigationAction.request)
            return nil
        }
        
        let popupWebView:WKWebView = .init(frame: .zero, configuration: configuration)
        popupWebView.tap_allowInspectionInDebugBuilds()
        // The popup fires the same web sdk callbacks and can open windows of its own
        popupWebView.navigationDelegate = self
        popupWebView.uiDelegate = self
        
        // The button itself is only as tall as the form, the identity flow needs the whole screen
        let popupViewController:PayButtonPopupViewController = .init(popupWebView: popupWebView)
        popupViewController.selectedLocale = currentlyLoadedConfigurations?.getButtonLocale() ?? "en"
        popupViewController.popupClosedByUser = { [weak self] in
            self?.popupViewController = nil
            self?.delegate?.onCanceled?()
        }
        self.popupViewController = popupViewController
        
        DispatchQueue.main.async {
            UIApplication.shared.topViewController()?.present(popupViewController, animated: true)
        }
        
        return popupWebView
    }
    
    /// The page closed the window it opened, ex click to pay finished and handed its result to the form
    public func webViewDidClose(_ webView: WKWebView) {
        guard webView === popupViewController?.popupWebView else { return }
        let closingPopup:PayButtonPopupViewController? = popupViewController
        popupViewController = nil
        DispatchQueue.main.async {
            closingPopup?.dismiss(animated: true)
        }
    }
}
