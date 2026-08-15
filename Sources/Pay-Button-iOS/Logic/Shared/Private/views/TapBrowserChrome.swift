//
//  TapBrowserChrome.swift
//  Pay-Button-iOS
//
//  Every page the sdk puts in front of the payer is the same thing wearing the same clothes .. a
//  web view with the powered by tap bar over it. The 3ds page and the windows the web sdk opens
//  with `window.open` were each dressing themselves, and drifted apart doing it.
//
//  This is that look, written once. A page that wants it asks for it rather than rebuilding it.
//

import UIKit
import WebKit

/// The look and the presentation every sdk page shares
internal enum TapBrowserChrome {

    /// How tall the powered by tap bar is
    internal static let barHeight: CGFloat = 56
    /// Where the page starts, 12 short of the bar so the bar overlaps it and no seam shows through
    internal static let pageTopInset: CGFloat = 44

    /// Presents a page the way every sdk page is presented .. a sheet, and one the payer can not
    /// swipe away, since a half dismissed page leaves whatever it hosts unfinished
    /// - Parameter controller: The page about to be presented
    internal static func applyPresentation(to controller: UIViewController) {
        controller.modalPresentationStyle = .pageSheet
        controller.isModalInPresentation = true
    }

    /// Applies the look to the page's own view. Opaque, so nothing behind the sheet shows through a
    /// strip the bar and the web view do not cover between them
    /// - Parameter controller: The page being laid out
    internal static func applyBackground(to controller: UIViewController) {
        controller.view.backgroundColor = .white
    }

    /// Applies the look to a web view, whoever built it
    /// - Parameter webView: The web view the page renders in
    internal static func style(_ webView: WKWebView) {
        webView.isOpaque = false
        webView.backgroundColor = .white
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.bounces = false
        webView.layer.cornerRadius = 0
        webView.clipsToBounds = true
    }

    /// Puts the web view and the bar on screen, pinned the same way in every page.
    ///
    /// The bar goes on last so it sits in front, covering the top of the page rather than being
    /// covered by it, and both hang off the safe area .. which is the top of the sheet
    /// - Parameter webView: The page to show
    /// - Parameter bar: The bar to show over it
    /// - Parameter controller: The page hosting both
    internal static func install(webView: UIView, bar: PoweredByTapView, in controller: UIViewController) {
        let container: UIView = controller.view

        container.addSubview(webView)
        container.addSubview(bar)

        webView.translatesAutoresizingMaskIntoConstraints = false
        bar.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            webView.topAnchor.constraint(equalTo: container.safeAreaLayoutGuide.topAnchor, constant: pageTopInset),
            webView.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            bar.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            bar.heightAnchor.constraint(equalToConstant: barHeight),
            bar.topAnchor.constraint(equalTo: container.safeAreaLayoutGuide.topAnchor)
        ])

        DispatchQueue.main.async {
            container.setNeedsLayout()
        }
    }
}
