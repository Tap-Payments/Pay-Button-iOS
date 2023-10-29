//
//  PayButtonParentView.swift
//  
//
//  Created by Osama Rabie on 26/10/2023.
//

import UIKit

@MainActor internal class PayButtonBaseView:UIView {

    var delegate:PayButtonDelegate?
    var payButtonType:PayButtonTypeEnum = .BenefitPay
    
    func initPayButton(configDict: [String : Any], delegate: PayButtonDelegate? = nil) {
        fatalError("must be implemented")
    }
}
