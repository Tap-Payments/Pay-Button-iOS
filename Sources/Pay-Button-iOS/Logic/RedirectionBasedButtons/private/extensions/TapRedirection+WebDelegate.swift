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
            case _ where url.absoluteString.contains(CallBackSchemeEnum.onBinIdentification.rawValue):
                self.delegate?.onBinIdentification?(data: tap_extractDataFromUrl(url.absoluteURL))
                break
            case _ where url.absoluteString.contains(CallBackSchemeEnum.on3dsRedirect.rawValue):
                handleRedirection(data: tap_extractDataFromUrl(url.absoluteURL))
                break
            case _ where url.absoluteString.contains(CallBackSchemeEnum.onHeightChange.rawValue):
                self.handleOnHeightChange(newHeight: Double(tap_extractDataFromUrl(url, for: "data", shouldBase64Decode: false)) ?? 48)
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
              let chargeID:String = redirection.id else {
            // This means, there is such an error from the integration with web sdk
            delegate?.onError?(data: "Failed to start authentication process")
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
    /// - Parameter cardBased: Indicates if we will need to pass the authentication back to the card pay button ot we will pass the normal ID we got from a normal redirection based payment method
    func showRedirectionView(for redirection:Redirection, cardBased:Bool = false) {
        // This means we are ok to start the authentication process
        threeDsView = .init()
        threeDsView?.isModalInPresentation = true
        // Set to web view the needed urls
        /// The redirect url scheme
        threeDsView?.redirectUrl = redirection.redirectionUrl ?? payButtonType.tapRedirectionSchemeUrl()
        threeDsView?.redirectionData = redirection
        threeDsView?.queryOnly = !cardBased
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
                    self.passRedirectionDataToSDK(rediectionUrl: redirectionUrl, cardBased: cardBased)
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
    
    /// Executes the logic needed where the web sdk is telling is onSuccess
    /// - Parameter url: the full web scheke url passed from the web sdk
    func handleOnSuccess(url:URL) {
        self.delegate?.onSuccess?(data: tap_extractDataFromUrl(url, for: "data", shouldBase64Decode: true))
        //self.openUrl(url: self.currentlyLoadedConfigurations)
    }
    
    
    /// Will handle & starte the redirection process when called
    /// - Parameter data: The data string fetched from the url parameter
    func handleRedirection(data:String) {
        // let us make sure we have the data we need to start such a process
        guard let cardRedirection:CardRedirection = try? CardRedirection(data),
              let _:String = cardRedirection.threeDsUrl,
              let _:String = cardRedirection.redirectUrl else {
            // This means, there is such an error from the integration with web sdk
            delegate?.onError?(data: "Failed to start authentication process")
            return
        }
        
        showRedirectionView(for: .init(url: cardRedirection.threeDsUrl, redirectionUrl: cardRedirection.redirectUrl, id: cardRedirection.keyword, powered: cardRedirection.powered, stopRedirection: false), cardBased: true)
    }
    
    /// Executes the logic needed where the web sdk is telling is changing in height
    /// - Parameter data: the new height passed from the web sdk
    func handleOnHeightChange(newHeight:Double) {
        // make sure we are in the main thread
        DispatchQueue.main.async {
            // move to the new height or safely to the default height
            let currentWidth:CGFloat = self.frame.width
            
            let buttonHeight = self.heightAnchor.constraint(equalToConstant: newHeight + 10.0)
            let buttonWidth = self.widthAnchor.constraint(equalToConstant: currentWidth)
            
            // Activate the constraints
            self.constraints.first { $0.firstAnchor == self.heightAnchor }?.isActive = false
            self.constraints.first { $0.firstAnchor == self.widthAnchor }?.isActive = false
            NSLayoutConstraint.activate([buttonHeight,buttonWidth])
            // Update the layout of the affected views
            self.layoutIfNeeded()
            self.updateConstraints()
            self.layoutSubviews()
            self.webView.layoutIfNeeded()
            self.delegate?.onHeightChange?(height: newHeight)
        }
        
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
