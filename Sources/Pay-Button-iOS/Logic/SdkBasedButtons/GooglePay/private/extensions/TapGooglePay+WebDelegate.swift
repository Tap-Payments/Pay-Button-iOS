//
//  File.swift
//  
//
//  Created by Osama Rabie on 02/11/2023.
//

import Foundation
import UIKit
import WebKit
import SharedDataModels_iOS


/// An extension to take care of the notifications being sent from the web view through the url schemes
extension GooglePayButton:WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        var action: WKNavigationActionPolicy?
        
        defer {
            decisionHandler(action ?? .allow)
        }
        
        guard let url = navigationAction.request.url else { return }
        
        if url.absoluteString.hasPrefix(payButtonType.webSdkScheme()) {
            //print("navigationAction", url.absoluteString)
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
                let _ = self.handleOnSuccess(url:url)
                break
            case _ where url.absoluteString.contains(CallBackSchemeEnum.onReady.rawValue):
                delegate?.onReady?()
                break
            case _ where url.absoluteString.contains(CallBackSchemeEnum.onClick.rawValue):
                delegate?.onClick?()
                break
            case _ where url.absoluteString.contains(CallBackSchemeEnum.onCancel.rawValue):
                let _ = self.removeGooglePayPopupEntry {
                    self.delegate?.onCanceled?()
                }
                break
            case _ where url.absoluteString.contains(CallBackSchemeEnum.onClosePopup.rawValue):
                let _ = self.removeGooglePayPopupEntry {
                    self.delegate?.onCanceled?()
                }
                break
            default:
                break
            }
        }else if url.absoluteString.hasPrefix(googlePaySDKUrlScheme) && url.absoluteString.lowercased().contains(googlePaySDKPopupKeyword) {
            action = .cancel
            // This means, GooglePay popup wil be displayed and we need to make our weview full screen
            // Googlepay uses this scheme mu;tuple times during the same payments, so we need to make sure that we are nont already preseting the popup
            guard UIApplication.shared.topViewController()?.restorationIdentifier != "GooglePayVC" else { return }
            showGooglePay(for: url)
            //topController.googlePayUrl = url.absoluteString
            //topController.startLoading()
        }else if url.absoluteString.contains("__WA_RES__") {
            action = .cancel
            let _ =  self.removeGooglePayPopupEntry {
                self.delegate?.onCanceled?()
            }
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
        // Let us see if we have to redirect or now
        if !(redirection.stopRedirection ?? false) {
            showRedirectionView(for: redirection)
        }
    }
    
    /// Handles the case and the post logic needed after getting onSuccess from the web sdk
    /// - Parameter url: The url passed from web sdk to indicae it is an onSuccess with needed data
    func handleOnSuccess(url:URL) {
        self.webView.isHidden = false
        let _ =  self.removeGooglePayPopupEntry {
            self.delegate?.onSuccess?(data: tap_extractDataFromUrl(url, for: "data", shouldBase64Decode: true))
        }
    }
    
    /// Handles the case and the post logic needed after getting onError from the web sdk
    /// - Parameter url: The url passed from web sdk to indicae it is an onError with needed data
    func handleOnError(data:String) {
        self.webView.isHidden = false
        
        let _ = self.removeGooglePayPopupEntry {
            self.delegate?.onError?(data:data)
            self.webView.isUserInteractionEnabled = true
        }
    }
    
    
    /// Will create a full screen modal to show the google pay flow
    /// - Parameter for url: The URL generated by the google pay sdk to complete this payment
    func showGooglePay(for url:URL) {
        // Let us init a modal view controller
        googlePayController = .init()
        googlePayController?.isModalInPresentation = true
        googlePayController?.restorationIdentifier = "GooglePayVC"
        googlePayController?.selectedLocale = currentlyLoadedConfigurations?.getButtonLocale() ?? "en"
        googlePayController?.googlePayCanceled = {
            self.googlePayController?.dismiss(animated: true) {
                self.openUrl(url: self.currentlyLoadedConfigurations)
            }
        }
        // Set to web view the needed urls
        /// The redirect url scheme
        googlePayController?.googlePayUrl = url.absoluteString
        // Set to web view what should it when the process is completed by the user
        googlePayController?.redirectionReached = { redirectionUrl in
            self.googlePayController?.dismiss(animated: true) {
                DispatchQueue.main.async {
                    // The decoded token if any
                    let token:String = self.fetchGooglePayToken(from: redirectionUrl)
                    // pass to the sdk
                    self.passToSDK(googlePayToken: token, fullUrl: redirectionUrl)
                }
            }
        }
        googlePayController?.startLoading()
        DispatchQueue.main.async {
            UIApplication.shared.topViewController()!.present(self.googlePayController!, animated: true)
        }
    }
    
    /// Gets the json part of the google pay token after redirecting from google pay sdk itself
    /// - Parameter url: The url google pay redirected the user to after finishing the payment flow
    func fetchGooglePayToken(from url:String) -> String {
        // Remove non needed parts
        let filtered:String = url.replacingOccurrences(of: "\(self.currentlyLoadedConfigurations?.absoluteString ?? "")#__WA_RES__=", with: "")
        // Turn it into pretty json string
        let decoded:String = filtered.removingPercentEncoding ?? ""
        if let json = try? JSONSerialization.jsonObject(with: Data(decoded.utf8), options: .mutableContainers),
           let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed) {
            // If parsable, let us send this object
            return String(decoding: jsonData, as: UTF8.self)
            
        }
        return ""
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
    
    /// Handles the onCancel when the user is 3ds page on google pay card and wants to go back :)
    func handleOnCancel() {
        self.delegate?.onCanceled?()
        self.webView.evaluateJavaScript("window.cancel()")
    }
    
}



extension GooglePayButton:WKUIDelegate {
   
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        //let (viewController,web,_) = createBenefitPayWithAppPopupView()
        
        if let url = navigationAction.request.url {
            //print("POPUP : \(url.absoluteString)")
            /*web.load(navigationAction.request)
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                //self.updateLoadingView(with: false)
                if let topMost:UIViewController = UIApplication.shared.topViewController() {
                    topMost.present(viewController, animated: true)
                }
            }*/
        }
        return nil
    }
}
