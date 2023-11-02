//
//  TapGooglePayView.swift
//  
//
//  Created by Osama Rabie on 02/11/2023.
//

import UIKit
import WebKit
import SharedDataModels_iOS


class GooglePayButton: PayButtonBaseView {
    /// The scheme prefix used by google pay sdk to show the google pay popup
    let googlePaySDKUrlScheme:String = "https://pay.google.com"
    /// The scheme prefix used by gppge pay sdk to show the google pay popup
    let googlePaySDKPopupKeyword:String = "pay?ng=true"
    /// The web view used to render the google pay button
    internal var webView: WKWebView = .init()
    /// keeps a hold of the loaded web sdk configurations url
    internal var currentlyLoadedConfigurations:URL?
    /// The view that will present full screen Google Pay flow
    internal var googlePayController:GooglPayPopupViewController?
    /// The view that will present full screen 3ds flow
    internal var threeDsView:ThreeDSView?
    
    //MARK: - Init methods
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    
    //MARK: - Private methods
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        // Set the button type
        payButtonType = .GooglePay
        // Setuo the web view contais the web sdk
        setupWebView()
        // setup the constraint to put each view in its correct positiob
        setupConstraints()
    }
    
    /// Used to open a url inside the Tap button web sdk.
    /// - Parameter url: The url needed to load.
    internal func openUrl(url: URL?) {
        // Store it for further usages
        currentlyLoadedConfigurations = url
        // instruct the web view to load the needed url
        let request = URLRequest(url: url!)
        
        
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.load(request)
    }
    
    
    /// used to setup the constraint of the Tap button sdk view
    private func setupWebView() {
        // Creates needed configuration for the web view
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        
        webView = WKWebView(frame: .zero, configuration: configuration)
        // Let us make sure it is of a clear background and opaque, not to interfer with the merchant's app background
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        webView.scrollView.backgroundColor = UIColor.clear
        webView.scrollView.bounces = false
        webView.isHidden = false
        // Let us add it to the view
        self.backgroundColor = .clear
        self.addSubview(webView)
    }
    
    
    
    /// Setup Constaraints for the sub views.
    private func setupConstraints() {
        // Preprocessing needed setup
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        // Define the web view constraints
        let top  = webView.topAnchor.constraint(equalTo: self.topAnchor)
        let left = webView.leftAnchor.constraint(equalTo: self.leftAnchor)
        let right = webView.rightAnchor.constraint(equalTo: self.rightAnchor)
        let bottom = webView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        let buttonHeight = self.heightAnchor.constraint(greaterThanOrEqualToConstant: 48)
        // SWIPE let buttonHeight = self.heightAnchor.constraint(greaterThanOrEqualToConstant: 48)
        
        // Activate the constraints
        NSLayoutConstraint.activate([left, right, top, bottom, buttonHeight])
        webView.layoutIfNeeded()
        webView.updateConstraints()
        self.layoutIfNeeded()
    }
    
    /// Will add the web view again to the normal view after removing it from the popup screen we presented to show the benefitpay popup
    internal func addWebViewToContainerView() {
        DispatchQueue.main.async {
            self.webView.removeFromSuperview()
            self.webView.frame = .zero
            self.addSubview(self.webView)
            self.setupConstraints()
        }
    }
    
    /// Call it when you want to remove the googlepay popyp and get back to the merchant app
    /// - Parameter onDismiss: a callback if needed to do some logic post closeing
    internal func removeGooglePayPopupEntry(onDismiss:@escaping()->()) -> Bool {
        guard let viewController:UIViewController = UIApplication.shared.topViewController(),
              viewController.restorationIdentifier == "GooglePayVC" else {
            onDismiss()
            return false
        }
        self.addWebViewToContainerView()
        viewController.dismiss(animated: true) {
            onDismiss()
        }
        return true
    }
    
    
    /// Tells the web sdk the process is finished with google ay and here is the oogle pay's response
    /// - Parameter googlePayToken: The parsed json of the google pay token part if any
    /// - Parameter fullUrl: The full redirection url from google just in case we have to fetch something
    internal func passToSDK(googlePayToken:String, fullUrl:String) {
        // The web sdk wants the query parameters only
        // BASE 64
        let base64Token:String = Data(googlePayToken.utf8).base64EncodedString()
        print("window.sendPaymentRequest('\(base64Token)');");
        
        webView.evaluateJavaScript("window.sendPaymentRequest('\(base64Token)');")
        //generateTapToken()
    }
    
    
    /// Tells the web sdk the process is finished with the data from backend
    /// - Parameter rediectionUrl: The url with the needed data coming from back end at the end of the currently running process
    internal func passRedirectionDataToSDK(rediectionUrl:String) {
        // The web sdk wants the query parameters only
        webView.evaluateJavaScript("window.retrieve('\(rediectionUrl)')")
        //generateTapToken()
    }
    
    //MARK: - Public init methods
    ///  configures the google pay button with the needed configurations for it to work
    ///  - Parameter config: The configurations dctionary. Recommended, as it will make you able to customly add models without updating
    ///  - Parameter delegate:A protocol that allows integrators to get notified from events fired from google  pay button
    override internal func initPayButton(configDict: [String : Any], delegate: PayButtonDelegate? = nil) {
        self.delegate = delegate
        //let operatorModel:Operator = .init(publicKey: configDict["publicKey"] as? String ?? "", metadata: generateApplicationHeader())
        var updatedConfigurations:[String:Any] = configDict
        
        
        do {
            currentlyLoadedConfigurations = try URL(string:UrlBasedUtils.generatePayButtonSdkURL(from: updatedConfigurations, payButtonType: payButtonType)) ?? nil
            updatedConfigurations["headers"] = UrlBasedUtils.generateApplicationHeader(headersEncryptionPublicKey: currentlyLoadedConfigurations?.headersEncryptionPublicKey() ?? "")
            updatedConfigurations["redirect"] = ["url":payButtonType.tapRedirectionSchemeUrl()]
            try openUrl(url: URL(string: UrlBasedUtils.generatePayButtonSdkURL(from: updatedConfigurations, payButtonType: payButtonType)))
        }
        catch {
            self.delegate?.onError?(data: "{error:\(error.localizedDescription)}")
        }
    }
    
}
