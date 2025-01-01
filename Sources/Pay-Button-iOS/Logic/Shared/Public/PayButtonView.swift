//
//  PayButtonView.swift
//  
//
//  Created by Osama Rabie on 26/10/2023.
//

import UIKit

@objc public class PayButtonView: UIView {

    internal var delegate:PayButtonDelegate?
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
    
    private func generateTheView(with payButtonType:PayButtonTypeEnum) {
        buttonView.removeFromSuperview()
        switch payButtonType {
        case .BenefitPay:
            buttonView = BenefitPayButton()
        case .Knet:
            buttonView = RedirectionPayButton()
            (buttonView as? RedirectionPayButton)?.updateType(to: .Knet)
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
            buttonView = GooglePayButton()
        case .CareemPay:
            buttonView = RedirectionPayButton()
            (buttonView as? RedirectionPayButton)?.updateType(to: .CareemPay)
        }
        addSubview(buttonView)
        buttonView.translatesAutoresizingMaskIntoConstraints = false
    }
    
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
            if let url = URL(string: "https://tap-sdks.b-cdn.net/mobile/paybutton/1.0.0/base_url.json") {
                var cdnRequest = URLRequest(url: url)
                cdnRequest.timeoutInterval = 2
                cdnRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
                URLSession.shared.dataTask(with: cdnRequest) { data, response, error in
                     if let data = data {
                         do {
                             if let cdnResponse:[String:String] = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String],
                                let cdnBaseUrlString:String = cdnResponse["baseURL"], cdnBaseUrlString != "",
                                let cdnBaseUrl:URL = URL(string: cdnBaseUrlString),
                                let sandboxEncryptionKey:String = cdnResponse["testEncKey"],
                                let buttonWrapperUrlFormat:String = cdnResponse["payButtonUrlFormat"],
                                let productionEncryptionKey:String = cdnResponse["prodEncKey"],
                                let fireBaseURL:String = cdnResponse["iOSFirebaseURL"],
                                let fireBaseJS:String = cdnResponse["iOSFireBaseJS"],
                                let redirectionKeyWord:String = cdnResponse["redirectionKeyWord"] {
                                 UrlBasedUtils.sandboxEncryptionKey = sandboxEncryptionKey
                                 UrlBasedUtils.productionEncryptionKey = productionEncryptionKey
                                 UrlBasedUtils.checkoutMWBaseURL = cdnBaseUrlString
                                 UrlBasedUtils.buttonWrapperUrlFormat = buttonWrapperUrlFormat
                                 UrlBasedUtils.redirectionKeyWord = redirectionKeyWord
                                 BenefitPayButton.benefitPayFireBaseURL = fireBaseURL
                                 BenefitPayButton.javaScriptCodeToSkipManInTheMiddle = fireBaseJS
                             }
                         } catch {}
                      }
                    // we need to update the intent with the sdk info
                    self.postLoadingFromCDN(configDict: configDict, delegate: delegate)
                  }.resume()
            }else{
                // Use the default embedded values as a fallback of all we need to update the intent with the sdk info
                postLoadingFromCDN(configDict: configDict, delegate: delegate)
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
        if let intentModel:[String:String] = configDict["intent"] as? [String:String],
           let intentID:String = intentModel["id"],
           let operatorModel:[String:String] = configDict["operator"] as? [String:String],
           let publicKey:String = operatorModel["publicKey"] {
            do {
                // We first need to call update sdk info api with the device & sdk details
                try UrlBasedUtils.updateSDKInfo(for: intentID, with: UrlBasedUtils.generateSDKINFO(for: publicKey)) {response, error  in
                    // Now let us see if any error happened or not
                    if let nonNullError = error {
                        DispatchQueue.main.async {
                            self.delegate?.onError?(data: "{error:\(error)}")
                            completion(nil)
                        }
                    }else{
                        // let us know if it is a special type (in this case BenefitPay)
                        if let  configs:[String:Any] = response?["config"] as? [String : Any],
                           let  acceptance:[String:Any] = configs["acceptance"] as? [String : Any],
                           let  supportedPaymentMethods:[String] = acceptance["supported_payment_methods"] as? [String],
                           supportedPaymentMethods.count > 0,
                           let paymentMethod:String = supportedPaymentMethods.first?.lowercased() {
                            // Check if it is benefitpay
                            if(paymentMethod.contains("benefit") && paymentMethod.contains("pay")) {
                                completion(.BenefitPay)
                            }else{
                                completion(.Knet)
                            }
                        }
                    }
                }
            }catch {
                self.delegate?.onError?(data: "{error:\(error.localizedDescription)}")
                completion(nil)
            }
        }else{
            self.delegate?.onError?(data: "{error:Please make sure to pass at least the following data: public key and intent id.}")
            completion(nil)
        }
    }
}
