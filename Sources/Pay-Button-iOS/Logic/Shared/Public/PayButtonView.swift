//
//  PayButtonView.swift
//  
//
//  Created by Osama Rabie on 26/10/2023.
//

import UIKit

/// The PayButton view .. interface to the pay button sdk
@objcMembers public class PayButtonView: UIView {
    /// The delegate that listents to the events from the pay button
    internal var delegate:PayButtonDelegate?
    /// The reference to the pay button view itself
    internal var buttonView:PayButtonBaseView = .init()
    
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
        backgroundColor = .clear
    }
    
    /// This creates and sets the internal type based on the passed button type
    /// - Parameter with payButtonType: The needed button to be rendered
    private func generateTheView(with payButtonType:PayButtonTypeEnum) {
        // let us remove if it was there before
        buttonView.removeFromSuperview()
        switch payButtonType {
        case .BenefitPay:
            buttonView = BenefitPayButton()
        case .Knet:
            buttonView = RedirectionPayButton()
            (buttonView as? RedirectionPayButton)?.updateType(to: .Knet)
        case .DEEMA:
            buttonView = RedirectionPayButton()
            (buttonView as? RedirectionPayButton)?.updateType(to: .DEEMA)
        case .ApplePay:
            buttonView = RedirectionPayButton()
            (buttonView as? RedirectionPayButton)?.updateType(to: .ApplePay)
        case .Fawry:
            buttonView = RedirectionPayButton()
            (buttonView as? RedirectionPayButton)?.updateType(to: .Fawry)
        case .Benefit:
            buttonView = RedirectionPayButton()
            (buttonView as? RedirectionPayButton)?.updateType(to: .Benefit)
        case .Paypal:
            buttonView = RedirectionPayButton()
            (buttonView as? RedirectionPayButton)?.updateType(to: .Paypal)
        case .Tabby:
            buttonView = RedirectionPayButton()
            (buttonView as? RedirectionPayButton)?.updateType(to: .Tabby)
        case .GooglePay:
            // Google pay is rendered by the web page like any other redirection based method.
            // The backend reports it as `google_pay`, which lands on the default branch below anyway
            buttonView = RedirectionPayButton()
            (buttonView as? RedirectionPayButton)?.updateType(to: .GooglePay)
        case .Click2Pay:
            buttonView = RedirectionPayButton()
            (buttonView as? RedirectionPayButton)?.updateType(to: .Click2Pay)
        case .Card:
            buttonView = RedirectionPayButton()
            (buttonView as? RedirectionPayButton)?.updateType(to: .Card)
        case .CareemPay:
            buttonView = RedirectionPayButton()
            (buttonView as? RedirectionPayButton)?.updateType(to: .CareemPay)
            (buttonView as? RedirectionPayButton)?.webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2.1 Safari/605.1.15"
        }
        // Add the view now to the screen
        addSubview(buttonView)
        // Stop the auto constraints so we can adjust the button sizes when needed
        buttonView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    /// The function that setups up the constraints of the button
    private func setupConstraints() {
        // Preprocessing needed setup
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        
        // Define the web view constraints
        let top  = buttonView.topAnchor.constraint(equalTo: self.topAnchor)
        let left = buttonView.leftAnchor.constraint(equalTo: self.leftAnchor)
        let right = buttonView.rightAnchor.constraint(equalTo: self.rightAnchor)
        let bottom = buttonView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        //let buttonHeight = self.heightAnchor.constraint(greaterThanOrEqualToConstant: 48)
        // SWIPE let buttonHeight = self.heightAnchor.constraint(greaterThanOrEqualToConstant: 48)
        
        // Activate the constraints
        NSLayoutConstraint.activate([left, right, top, bottom])
        buttonView.layoutIfNeeded()
        buttonView.updateConstraints()
        self.layoutIfNeeded()
    }
    
    
    
    //MARK: - Public init methods
    ///  configures the benefit pay button with the needed configurations for it to work
    ///  - Parameter config: The configurations dctionary. Recommended, as it will make you able to customly add models without updating
    ///  - Parameter delegate:A protocol that allows integrators to get notified from events fired from benefit pay button
    @objc public func 
    initPayButton(configDict: [String : Any], delegate: PayButtonDelegate? = nil) {
        // First let us make sure we got the data we need
        // Make sure we got the minimum required data
        if let intentModel:[String:Any] = configDict["intent"] as? [String:Any],
           let intentID:String = intentModel["id"] as? String,
           let operatorModel:[String:Any] = configDict["operator"] as? [String:Any],
           let publicKey:String = operatorModel["publicKey"]  as? String {
            UrlBasedUtils.intentID = intentID
            UrlBasedUtils.publicKey = publicKey
            // Then we need to load base url and encryption keys from cdn
            // We will first need to try to load the latest base url from the CDN to make sure our backend doesn't want us to look somewhere else
            UrlBasedUtils.loadCDNConfiguration {
                // we need to update the intent with the sdk info
                self.postLoadingFromCDN(configDict: configDict, delegate: delegate)
            }
        }
    }

    /// Performs the needed logic after getting base url, encryption keys from the CDN
    /// - Parameter configDict: The button configs passed from merchant
    /// - Parameter delegate: The pay button delegate
    internal func postLoadingFromCDN(configDict: [String : Any], delegate: PayButtonDelegate? = nil) {
        DispatchQueue.main.async {
            // Then of all we need to update the intent with the sdk info
            self.UpdateSDKInfo(configDict: configDict) { detectedPayButtonEnum in
                DispatchQueue.main.async {
                    self.generateTheView(with: detectedPayButtonEnum ?? .Knet)
                    self.setupConstraints()
                    self.buttonView.initPayButton(configDict: configDict, delegate: delegate)
                }
            }
        }
    }
    /// Update the intent with the sdk info
    internal func UpdateSDKInfo(configDict: [String : Any],completion: @escaping (_ detectedPayButtonEnum:PayButtonTypeEnum?) -> Void = {detectedPayButtonEnum in }) {
        // Make sure we got the minimum required data
        guard let intentModel:[String:String] = configDict["intent"] as? [String:String],
              let intentID:String = intentModel["id"],
              let operatorModel:[String:String] = configDict["operator"] as? [String:String],
              let publicKey:String = operatorModel["publicKey"] else {
            self.delegate?.onError?(data: "{error:Please make sure to pass at least the following data: public key and intent id.}")
            completion(nil)
            return
        }

        // This sdk created this very intent a moment ago, so the sdk info went out with the create call and the
        // configuration came back with it. Asking for both again only delays the button
        if intentID == UrlBasedUtils.createdIntentID,
           let createdIntentResponse:[String:Any] = UrlBasedUtils.createdIntentResponse {
            UrlBasedUtils.publicKey = publicKey
            UrlBasedUtils.currentInentID = intentID
            completion(detectPayButtonType(from: createdIntentResponse))
            return
        }

        do {
            // The intent was created elsewhere, ex the merchant's backend, so it still has to be stamped
            // with this device's details before it can be used
            try UrlBasedUtils.updateSDKInfo(for: intentID, with: UrlBasedUtils.generateSDKINFO(for: publicKey)) {response, error  in
                DispatchQueue.main.async {
                    // Now let us see if any error happened or not
                    if let error = error {
                        self.delegate?.onError?(data: "{error:\(error)}")
                        completion(nil)
                        return
                    }
                    completion(self.detectPayButtonType(from: response))
                }
            }
        }catch {
            self.delegate?.onError?(data: "{error:\(error.localizedDescription)}")
            completion(nil)
        }
    }

    /// Reads which button to render out of an intent's configuration.
    /// Returns nil when the response does not carry one, the caller falls back to the redirection button
    /// - Parameter from response: The intent as the backend returned it, either from create or from the sdk update
    internal func detectPayButtonType(from response:[String:Any]?) -> PayButtonTypeEnum? {
        guard let configs:[String:Any] = response?["config"] as? [String : Any],
              let acceptance:[String:Any] = configs["acceptance"] as? [String : Any],
              let supportedPaymentMethods:[String] = acceptance["supported_payment_methods"] as? [String],
              let paymentMethod:String = supportedPaymentMethods.first?.lowercased() else {
            return nil
        }
        // Check if it is benefitpay
        if paymentMethod.contains("benefit") && paymentMethod.contains("pay") {
            return .BenefitPay
        }
        // Check if it is careempay to adjust the user agent of the webview
        if paymentMethod.contains("careem") && paymentMethod.contains("pay") {
            return .CareemPay
        }
        return .Knet
    }
}
