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
        
        if url.absoluteString.hasPrefix(payButtonType.webSdkScheme()) {
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
        }else if url.absoluteString.hasPrefix(payButtonType.tapRedirectionSchemeUrl()) {
            
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
            delegate?.onError?(data: "Failed to start authentication process")
            return
        }
        // Let us pass the charge created id for the delegae
        self.delegate?.onChargeCreated?(data: chargeID)
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
