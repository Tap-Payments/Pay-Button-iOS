//
//  PayButtonPopupViewController.swift
//
//  Hosts a window the card web sdk opened with `window.open`, ex the click to pay identity flow.
//

import UIKit
import WebKit
import SharedDataModels_iOS

/// Presents a popup the web sdk opened with `window.open`.
///
/// The web view is the one WebKit built for us in `createWebViewWith`, out of the opener's own
/// configuration, so it keeps its `window.opener` link and can post its result back to the page that
/// opened it. Click to pay relies on exactly that to hand the payer's selected card back to the form.
///
/// It wears the same clothes as the 3ds page, from `TapBrowserChrome`, since to the payer it is the
/// same kind of thing .. a page the sdk put in front of them with a way back out
internal class PayButtonPopupViewController: UIViewController {

    /// The popup web view, created out of the opener's configuration
    internal let popupWebView:WKWebView
    /// Called when the payer dismisses the popup themselves rather than letting the flow finish
    internal var popupClosedByUser:()->() = {}
    /// The popup has no chrome of its own, so it gets the same bar the 3ds page has
    internal let poweredByTapView:PoweredByTapView = .init(frame: .zero)
    /// Represents the locale needed to render the powered by tap view with
    internal var selectedLocale:String = "en" {
        didSet{
            self.poweredByTapView.selectedLocale = selectedLocale
        }
    }

    //MARK: - Init methods
    internal init(popupWebView:WKWebView) {
        self.popupWebView = popupWebView
        super.init(nibName: nil, bundle: nil)
        TapBrowserChrome.applyPresentation(to: self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        TapBrowserChrome.applyBackground(to: self)
        TapBrowserChrome.style(popupWebView)
        // The bar is what tells the payer whose page this is and how to leave it
        poweredByTapView.selectedLocale = selectedLocale
        poweredByTapView.backButtonClicked = { [weak self] in
            self?.dismiss(animated: true) {
                self?.popupClosedByUser()
            }
        }
        TapBrowserChrome.install(webView: popupWebView, bar: poweredByTapView, in: self)
    }
}
