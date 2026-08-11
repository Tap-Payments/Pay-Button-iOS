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
    /// The close button, the popup has no chrome of its own
    private let closeButton:UIButton = .init(type: .system)

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
        setupCloseButton()
    }

    //MARK: - Private methods
    /// Puts the popup web view on screen
    private func setupWebView() {
        view.addSubview(popupWebView)
        popupWebView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            popupWebView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            popupWebView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            popupWebView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            popupWebView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    /// The popup is a bare web view, so give the payer a way out of it
    private func setupCloseButton() {
        closeButton.setImage(UIImage(named: "Close", in: Bundle.currentBundle, with: nil), for: .normal)
        closeButton.tintColor = .darkGray
        closeButton.imageView?.contentMode = .scaleAspectFit
        closeButton.addTarget(self, action: #selector(closeButtonClicked), for: .touchUpInside)

        view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    /// The payer backed out of the popup
    @objc private func closeButtonClicked() {
        dismiss(animated: true) { [weak self] in
            self?.popupClosedByUser()
        }
    }
}
