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

    /// Stops the payer zooming the page.
    ///
    /// A payment form that pinches out of shape, or that jumps when a field is double tapped, reads
    /// as broken rather than as a feature. Two things are needed, since they are separate paths ..
    /// the scroll view zooms on a pinch, and webkit zooms on a double tap unless the page's own
    /// viewport says not to, which `WKWebViewConfiguration.tap_disableZoom()` handles
    func tap_disableZoom() {
        scrollView.pinchGestureRecognizer?.isEnabled = false
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 1
        scrollView.bouncesZoom = false
    }
}

internal extension WKWebViewConfiguration {

    /// Writes a viewport the page cannot zoom out of, before anything is loaded into it.
    ///
    /// The pages the sdk shows are not ours to edit, so the viewport is added to them on the way
    /// past. This is what stops a double tap zooming, which no scroll view setting reaches
    func tap_disableZoom() {
        let source:String = """
        var meta = document.querySelector('meta[name=viewport]') || document.createElement('meta');
        meta.name = 'viewport';
        meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
        if (!meta.parentNode) { document.head.appendChild(meta); }
        """
        let script:WKUserScript = .init(source: source,
                                        injectionTime: .atDocumentEnd,
                                        forMainFrameOnly: true)
        userContentController.addUserScript(script)
    }
}
