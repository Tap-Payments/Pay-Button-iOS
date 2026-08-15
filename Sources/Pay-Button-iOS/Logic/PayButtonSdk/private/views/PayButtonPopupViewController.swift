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
        // The identity flow needs the room, and a dismissed sheet would leave the popup half loaded
        modalPresentationStyle = .fullScreen
        isModalInPresentation = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupWebView()
        setupPoweredByTapView()
    }

    //MARK: - Private methods
    /// Puts the popup web view on screen
    private func setupWebView() {
        view.addSubview(popupWebView)
        popupWebView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            popupWebView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            popupWebView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // The bar sits at the top of the safe area and overlaps the page by 12, same as the 3ds page
            popupWebView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            popupWebView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    /// The popup is a bare web view, so the bar is what tells the payer whose page this is and how to leave it
    private func setupPoweredByTapView() {
        poweredByTapView.selectedLocale = selectedLocale
        poweredByTapView.backButtonClicked = { [weak self] in
            self?.dismiss(animated: true) {
                self?.popupClosedByUser()
            }
        }

        view.addSubview(poweredByTapView)
        poweredByTapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            poweredByTapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            poweredByTapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            poweredByTapView.heightAnchor.constraint(equalToConstant: 56),
            poweredByTapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
    }
}
