//
//  PayButtonParentView.swift
//  
//
//  Created by Osama Rabie on 26/10/2023.
//

import UIKit

@MainActor internal class PayButtonBaseView:UIView {

    var delegate:PayButtonDelegate?
    // Was `.BenefitPay`, which is commented out for now. Every remaining button is redirection based
    var payButtonType:PayButtonTypeEnum = .Knet
    
    func initPayButton(configDict: [String : Any], delegate: PayButtonDelegate? = nil) {
        fatalError("must be implemented")
    }
}
