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
    ///  - Parameter payButtonType: The type of the button you want to render
    @objc public func initPayButton(configDict: [String : Any], delegate: PayButtonDelegate? = nil, payButtonType:PayButtonTypeEnum) {
        generateTheView(with: payButtonType)
        setupConstraints()
        buttonView.initPayButton(configDict: configDict, delegate: delegate)
    }
}
