//
//  TapPayButton+WKWebView.swift
//
//
//  Created by Osama Rabie on 26/10/2023.
//

import Foundation
import WebKit

internal extension WKWebView {

    /// Lets Safari's web inspector attach to the web sdk running inside this web view.
    /// Debug builds only on purpose. A payment form that anyone can attach an inspector to
    /// is not something we want in a shipped app, so this stays off in release.
    ///
    /// To use it: run the app from Xcode, then Safari > Develop > <your simulator or device> > the tap page.
    /// Safari's Develop menu has to be enabled first from Safari > Settings > Advanced.
    func tap_allowInspectionInDebugBuilds() {
        #if DEBUG
        if #available(iOS 16.4, *) {
            isInspectable = true
        }
        #endif
    }
}
