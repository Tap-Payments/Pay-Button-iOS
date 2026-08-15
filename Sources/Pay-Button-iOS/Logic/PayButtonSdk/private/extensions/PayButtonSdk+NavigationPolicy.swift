//
//  PayButtonSdk+NavigationPolicy.swift
//  Pay-Button-iOS
//
//  Every navigation the web sdk attempts comes through here first. A url is either an event the
//  button sdk is firing at us, an event from the card form, or a real page to load, and this is
//  what tells them apart and hands each one to its own handler.
//

import Foundation
import UIKit
import WebKit
import SharedDataModels_iOS

/// Decides what to do with every navigation the web sdk attempts
extension PayButtonSdk:WKNavigationDelegate {

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
            
        }else if PayButtonSdk.requiresSystemBrowser(threeDsUrl: url.absoluteString),
                       threeDSSafariSession == nil {
            action = .cancel
            startFidoAuthentication(threeDsUrl: url.absoluteString,
                                    redirectUrl: lastCardRedirection?.redirectUrl)
            return
        }
    }
}
