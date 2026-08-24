//
//  PayButtonSdk+ThreeDS.swift
//  Pay-Button-iOS
//
//  Everything that runs an authentication .. the redirection page the shared buttons use, the card
//  form's own 3ds page, the passkey that has to leave the web view for safari, and handing the
//  answer back to whichever form asked for it.
//

import Foundation
import UIKit
import WebKit
import SharedDataModels_iOS

/// Runs the authentications the web sdk asks for
extension PayButtonSdk {

    /// Will create a redirection UIView and display it alert level on top of the current screen
    /// - Parameter for redirection: The redirection model that contains the redirection URL + the redirection finished keyword
    func showRedirectionView(for redirection:Redirection) {
        // This means we are ok to start the authentication process
        threeDsView = .init()
        // Set to web view the needed urls
        /// The redirect url scheme
        threeDsView?.redirectUrl = payButtonType.tapRedirectionSchemeUrl()
        threeDsView?.redirectionData = redirection
        // Set the selected card locale for correct semantic rendering
        threeDsView?.selectedLocale = currentlyLoadedConfigurations?.getButtonLocale() ?? "en"
        // Set to web view what should it when the process is canceled by the user
        threeDsView?.threeDSCanceled = {
            self.threeDsView = nil
            TapBrowserChrome.dismiss(name: TapBrowserChrome.threeDSEntryName) {
                self.handleOnCancel()
            }
        }
        // Hide or show the powered by tap based on coming parameter
        threeDsView?.poweredByTapView.isHidden = false
        // Set to web view what should it when the process is completed by the user
        threeDsView?.redirectionReached = { redirectionUrl in
            self.threeDsView = nil
            TapBrowserChrome.dismiss(name: TapBrowserChrome.threeDSEntryName) {
                DispatchQueue.main.async {
                    self.passRedirectionDataToSDK(rediectionUrl: redirectionUrl)
                }
            }
        }
        // Set to web view what should it do when the content is loaded in the background
        threeDsView?.idleForWhile = {
            self.threeDsView?.idleForWhile = {}
            DispatchQueue.main.async {
                guard let threeDsView = self.threeDsView else { return }
                TapBrowserChrome.present(threeDsView, name: TapBrowserChrome.threeDSEntryName)
            }
        }
        // Tell it to start rendering 3ds content in background
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
        if PayButtonSdk.requiresSystemBrowser(threeDsUrl: threeDsUrl, key: cardRedirection.keyword)  {
            startFidoAuthentication(with: cardRedirection)
            return
        }
        
        threeDsView = .init()
        threeDsView?.redirectionData = .init(url: threeDsUrl, id: nil, powered: cardRedirection.powered, stopRedirection: false)
        // Watch for the card sdk's own keyword instead of the shared redirection one
        threeDsView?.cardRedirectionKeyword = cardRedirection.keyword
        threeDsView?.selectedLocale = currentlyLoadedConfigurations?.getButtonLocale() ?? "en"
        threeDsView?.poweredByTapView.isHidden = !(cardRedirection.powered ?? true)
        threeDsView?.threeDSCanceled = {
            self.threeDsView = nil
            TapBrowserChrome.dismiss(name: TapBrowserChrome.threeDSEntryName) {
                self.handleCardAuthenticationCanceled()
            }
        }
        threeDsView?.redirectionReached = { redirectionUrl in
            self.threeDsView = nil
            TapBrowserChrome.dismiss(name: TapBrowserChrome.threeDSEntryName) {
                DispatchQueue.main.async {
                    self.passCardAuthenticationToSDK(redirectionUrl: redirectionUrl)
                }
            }
        }
        threeDsView?.idleForWhile = {
            self.threeDsView?.idleForWhile = {}
            DispatchQueue.main.async {
                guard let threeDsView = self.threeDsView else { return }
                TapBrowserChrome.present(threeDsView, name: TapBrowserChrome.threeDSEntryName)
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
        NSLog("PayButton: handing the card form \(redirectionUrl)")
        webView.evaluateJavaScript(javaScript) { result, error in
            // `none` means the page has neither function, ex the button page reloaded and took the
            // card iframe with it, so there is nobody left to finish the authentication
            NSLog("PayButton: loadAuthentication handled by \(result ?? "nil") \(error?.localizedDescription ?? "")")
        }
    }

    /// Decides whether the authentication has to leave the web view. An ACS url that advertises a
    /// passkey challenge can not run inside `WKWebView`, it does not expose `navigator.credentials`
    /// - Parameter threeDsUrl: The ACS page coming from the redirection details
    /// - Returns: True when the process belongs in the system browser
    internal static func requiresSystemBrowser(threeDsUrl:String?, key: String?) -> Bool {
        guard let threeDsUrl:String = threeDsUrl else { return false }
        guard let key:String = key else { return false }
        return threeDsUrl.contains("passkey") && key == "auth_payer"
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
        // One authentication, one browser. The card form can announce the same challenge more than
        // once, and starting a second session would put a second safari over the first .. finishing
        // then takes only the newest one down and leaves the payer looking at the one underneath
        guard threeDSPasskeySession == nil else {
            NSLog("PayButton: a passkey is already running, ignoring this one")
            NSLog("PayButton: it was for \(threeDsUrl ?? "nil")")
            return
        }

        NSLog("PayButton: running the passkey in ASWebAuthenticationSession")
        let passkeySession:ThreeDSPasskeySession = .init()
        passkeySession.delegate = self
        threeDSPasskeySession = passkeySession

        // The session claims the scheme itself, so nothing is declared in the host app. The return
        // page has to bounce to it, ex tapCardWebSDK://onPasskeyRedirect?data=...
        let callbackScheme:String = payButtonType.cardWebSdkScheme()
            .replacingOccurrences(of: "://", with: "")

        // A passkey that arrived as a bare navigation carries no redirection details, so fall
        // back to the return url the configured callback already names
        passkeySession.start(threeDsUrl: threeDsUrl,
                             redirectUrl: redirectUrl ?? PayButtonView.threeDSCallback.httpsReturnUrl,
                             callbackScheme: callbackScheme,
                             keyword: lastCardRedirection?.keyword,
                             in: window)
    }

    /// The payer backed out of the 3ds page
    internal func handleCardAuthenticationCanceled() {
        delegate?.onCanceled?()
        let javaScript:String = """
        (function() {
            if (window && typeof window.cancelAuthentication === 'function') {
                window.cancelAuthentication();
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
}

/// Receives the outcome of a passkey authentication that ran in the system browser
extension PayButtonSdk: ThreeDSPasskeySessionDelegate {

    /// The callback the browser came back on, before anything is read out of it
    func threeDSPasskeySession(_ session: ThreeDSPasskeySession, didReachCallback callbackUrl: URL) {
        NSLog("PayButton: the passkey came back on \(callbackUrl.absoluteString)")
    }

    /// The browser came back, hand the url over to the card form
    func threeDSPasskeySession(_ session: ThreeDSPasskeySession, didSucceedWith redirectionUrl: String) {
        threeDSPasskeySession = nil
        passCardAuthenticationToSDK(redirectionUrl: redirectionUrl)
    }

    /// The payer closed the browser before finishing the authentication
    func threeDSPasskeySessionDidCancel(_ session: ThreeDSPasskeySession) {
        threeDSPasskeySession = nil
        delegate?.onError?(data: "Payer canceled three ds process")
    }

    /// The process could not be completed, treat it the same as a failed start
    func threeDSPasskeySession(_ session: ThreeDSPasskeySession, didFailWith error: Error) {
        threeDSPasskeySession = nil
        delegate?.onError?(data: "Failed to start authentication process")
    }
}
