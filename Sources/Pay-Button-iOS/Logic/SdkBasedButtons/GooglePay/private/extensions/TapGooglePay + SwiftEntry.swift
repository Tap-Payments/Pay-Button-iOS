//
//  File.swift
//  
//
//  Created by Osama Rabie on 02/11/2023.
//

import Foundation
import WebKit

internal extension GooglePayButton {
    
    
    /// Will create a view that contains a full screen web view to display within the google pay modal popup
    func createGooglePayPopUpView() -> UIViewController {
        // The container iew
        let view:UIView = .init()
        view.backgroundColor = .clear
        
        //webView.isHidden = true
        webView.removeFromSuperview()
        view.addSubview(webView)
        
        // Define the constrains of the web view to be full screen
        let top  = webView.topAnchor.constraint(equalTo: view.topAnchor)
        let left = webView.leftAnchor.constraint(equalTo: view.leftAnchor)
        let right = webView.rightAnchor.constraint(equalTo: view.rightAnchor)
        let bottom = webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        // Activate the constraints
        NSLayoutConstraint.activate([left, right, top, bottom])
        
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        
        
        let ctr:UIViewController = .init()
        ctr.view.backgroundColor = .clear
        ctr.modalPresentationStyle = .overCurrentContext
        ctr.view.addSubview(view)
        ctr.restorationIdentifier = "GooglePayVC"
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let vtop  = view.topAnchor.constraint(equalTo: ctr.view.topAnchor)
        let vleft = view.leftAnchor.constraint(equalTo: ctr.view.leftAnchor)
        let vright = view.rightAnchor.constraint(equalTo: ctr.view.rightAnchor)
        let vbottom = view.bottomAnchor.constraint(equalTo: ctr.view.bottomAnchor,constant: 60)
        
        // Activate the constraints
        NSLayoutConstraint.activate([left, right, top, bottom, vtop, vleft, vright, vbottom])
        
        return ctr
    }
    
}
