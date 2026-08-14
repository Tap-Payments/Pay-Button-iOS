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

    /// How the system browser hands control back once a passkey authentication finishes.
    ///
    /// `.scheme("tapcardsdk")` needs nothing declared for the `authenticationSession` presentation,
    /// it intercepts the scheme itself, but the page served at the https return url has to bounce to
    /// `tapcardsdk://` carrying the same query string. The `safariViewController` presentation also
    /// wants the scheme in your Info.plist, since ios opens the app with it rather than handing it back.
    ///
    /// `.https(host:path:)` skips the bounce, the real return url completes the session. It needs
    /// three things together: ios 17.4, `webcredentials:<host>` in your Associated Domains, and the
    /// host serving an `apple-app-site-association` that names this app. Miss any of them and the
    /// session simply never comes back, there is no error to catch
    public static var threeDSCallback:ThreeDSCallback = .https(host: "sdk.dev.tap.company", path: "/")

    /// Whether the system browser runs as a private session during a passkey authentication.
    /// A private session drops the "<app> wants to use <domain> to sign in" consent alert, at the
    /// cost of Safari's shared cookies, so the issuer can not honour "remember this device".
    /// Passkeys themselves come from the platform authenticator and are unaffected either way
    public static var threeDSPrefersEphemeralSession:Bool = true
    
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
        //case .BenefitPay:
        //    buttonView = BenefitPayButton()
        case .Knet:
            buttonView = RedirectionPayButton()
            (buttonView as? RedirectionPayButton)?.updateType(to: .Knet)
        case .DEEMA:
            buttonView = RedirectionPayButton()
            (buttonView as? RedirectionPayButton)?.updateType(to: .DEEMA)
        case .ApplePay:
            buttonView = RedirectionPayButton()
            (buttonView as? RedirectionPayButton)?.updateType(to: .ApplePay)
        //case .Fawry:
        //    buttonView = RedirectionPayButton()
        //    (buttonView as? RedirectionPayButton)?.updateType(to: .Fawry)
        case .Benefit:
            buttonView = RedirectionPayButton()
            (buttonView as? RedirectionPayButton)?.updateType(to: .Benefit)
        case .Paypal:
            buttonView = RedirectionPayButton()
            (buttonView as? RedirectionPayButton)?.updateType(to: .Paypal)
        case .Tabby:
            buttonView = RedirectionPayButton()
            (buttonView as? RedirectionPayButton)?.updateType(to: .Tabby)
        case .TAMARA:
            buttonView = RedirectionPayButton()
            (buttonView as? RedirectionPayButton)?.updateType(to: .TAMARA)
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
        //case .CareemPay:
        //    buttonView = RedirectionPayButton()
        //    (buttonView as? RedirectionPayButton)?.updateType(to: .CareemPay)
        //    (buttonView as? RedirectionPayButton)?.webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2.1 Safari/605.1.15"
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
                            //if(paymentMethod.contains("benefit") && paymentMethod.contains("pay")) {
                            //    completion(.BenefitPay)
                            //}// Check if it is careempay to adjust the user agent of the webview
                            //else if(paymentMethod.contains("careem") && paymentMethod.contains("pay")) {
                            //    completion(.CareemPay)
                            //}else{
                                completion(.Knet)
                            //}
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
