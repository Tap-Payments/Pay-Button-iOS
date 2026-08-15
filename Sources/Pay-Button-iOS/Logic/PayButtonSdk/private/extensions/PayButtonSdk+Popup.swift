//
//  PayButtonSdk+Popup.swift
//  Pay-Button-iOS
//
//  The windows the web sdk opens with `window.open`, ex the click to pay identity flow.
//

import Foundation
import UIKit
import WebKit
import SharedDataModels_iOS

extension PayButtonSdk:WKUIDelegate {
    
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
