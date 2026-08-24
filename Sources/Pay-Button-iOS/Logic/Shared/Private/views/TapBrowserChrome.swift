//
//  TapBrowserChrome.swift
//  Pay-Button-iOS
//
//  Every page the sdk puts in front of the payer is the same thing wearing the same clothes .. a
//  web view with the powered by tap bar over it, floating over the button's own screen rather than
//  replacing it. The 3ds page and the windows the web sdk opens with `window.open` were each
//  dressing themselves, and drifted apart doing it.
//
//  This is that look, written once. A page that wants it asks for it rather than rebuilding it.
//
//  Ported from Card-iOS, which shows it through `SwiftEntryKit` rather than `UIViewController.present`.
//  That distinction is the whole reason the header reads as glass instead of a flat tinted rectangle.
//  A modally presented sheet manages the presenting screen as a separate layer and only leaves a
//  thin, system controlled gap of it visible .. an entry displayed by `SwiftEntryKit` sits over the
//  button's own screen in the same window instead, which stays genuinely on screen and rendered the
//  whole time, dimmed behind the entry rather than replaced by it. That is what a transparent bar
//  over a real backdrop blur needs behind it to be worth calling a blur at all
//

import UIKit
import WebKit
import SwiftEntryKit

/// The look and the presentation every sdk page shares
internal enum TapBrowserChrome {

    /// How tall the powered by tap bar is
    internal static let barHeight: CGFloat = 56
    /// Where the page starts, measured from the entry's own top .. the same 56 Card-iOS uses
    internal static let pageTopOffset: CGFloat = 56
    /// Where the bar starts, measured from the entry's own top. 12 short of where the page starts,
    /// so the bar overlaps it and no seam shows through
    internal static let barTopOffset: CGFloat = 12

    /// The name the 3ds page is shown under, so a later dismiss can find precisely this entry and
    /// nothing else
    internal static let threeDSEntryName = "TapThreeDS"
    /// The name a window the web sdk opened with `window.open` is shown under
    internal static let popupEntryName = "TapPopup"

    /// Shows a page the way every sdk page is shown.
    ///
    /// A floating card over the button's own screen, dimmed rather than replaced, the payer can not
    /// swipe away since a half dismissed page leaves whatever it hosts unfinished. Showing the same
    /// name twice replaces what was there instead of stacking a second one on top of it
    /// - Parameter entry: The page to show, already laid out via `install`
    /// - Parameter name: `threeDSEntryName` or `popupEntryName`
    internal static func present(_ entry: UIView, name: String) {
        var attributes: EKAttributes = .bottomFloat
        attributes.name = name
        attributes.entryBackground = .clear
        // Dims the button's own screen behind the entry rather than blurring it .. card-ios tried a
        // visual effect here and left it turned off, a flat colour is what actually ships
        attributes.screenBackground = .color(color: .init(light: .init(white: 0, alpha: 0.6),
                                                           dark: .init(red: 0.108, green: 0.108, blue: 0.108, alpha: 0.75)))
        attributes.displayDuration = .infinity
        attributes.entranceAnimation = .init(translate: .init(duration: 0.35))
        attributes.exitAnimation = .init(translate: .init(duration: 0.25))
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.25, radius: 5, offset: .zero))
        attributes.positionConstraints.size = .init(width: .fill, height: .ratio(value: 0.90))
        attributes.entryInteraction = .absorbTouches
        attributes.screenInteraction = .forward
        attributes.roundCorners = .all(radius: 8)
        attributes.positionConstraints.verticalOffset = -50
        attributes.positionConstraints.safeArea = .overridden
        attributes.scroll = .enabled(swipeable: false, pullbackAnimation: .jolt)

        SwiftEntryKit.display(entry: entry, using: attributes)
    }

    /// Takes a named page down. Harmless to call when nothing by that name is showing
    /// - Parameter name: `threeDSEntryName` or `popupEntryName`
    /// - Parameter completion: Run once it is off screen
    internal static func dismiss(name: String, then completion: @escaping () -> Void = {}) {
        SwiftEntryKit.dismiss(.specific(entryName: name), with: completion)
    }

    /// Applies the look to the page's own view.
    ///
    /// Clear, not opaque. The bar and the web view between them cover every pixel of it, so nothing
    /// of the entry's own view is ever left showing on its own .. but the bar carries a real backdrop
    /// blur, and a blur behind an opaque view has nothing to blur but that opaque colour. Clear lets
    /// it reach past the entry's own view to the button's own screen, dimmed behind it by
    /// `screenBackground` above, which is what the blur actually has to show through to
    /// - Parameter container: The page being laid out
    internal static func applyBackground(to container: UIView) {
        container.backgroundColor = .clear
    }

    /// Applies the look to a web view, whoever built it
    /// - Parameter webView: The web view the page renders in
    internal static func style(_ webView: WKWebView) {
        // The page is pinned to the bottom of the entry, but a scroll view pads its own content for
        // the safe area unless told not to, which leaves a strip of nothing under the page. The page
        // decides its own bottom
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.tap_disableZoom()
        webView.isOpaque = false
        webView.backgroundColor = .white
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.bounces = false
        webView.layer.cornerRadius = 0
        webView.clipsToBounds = true
    }

    /// Puts the web view and the bar on screen, pinned the same way in every page.
    ///
    /// The bar goes on first so the page sits in front of it. The bar starts 12 down from the
    /// entry's own top and is 56 tall, the page starts 56 down, so the page covers the bottom 12 of
    /// the bar .. which is what leaves the bar showing with the page beginning right at its edge, no
    /// seam and nothing of the page hidden underneath. The top 12 of the entry, above the bar, is
    /// left uncovered on purpose .. `SwiftEntryKit` rounds the whole entry's corners there, and a
    /// blurred, dimmed sliver of the button's own screen is meant to show through it
    /// - Parameter webView: The page to show
    /// - Parameter bar: The bar to show above it
    /// - Parameter container: The entry hosting both
    internal static func install(webView: UIView, bar: PoweredByTapView, in container: UIView) {
        container.addSubview(bar)
        container.addSubview(webView)

        webView.translatesAutoresizingMaskIntoConstraints = false
        bar.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            webView.topAnchor.constraint(equalTo: container.topAnchor, constant: pageTopOffset),
            webView.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            bar.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            bar.topAnchor.constraint(equalTo: container.topAnchor, constant: barTopOffset),
            bar.heightAnchor.constraint(equalToConstant: barHeight)
        ])

        DispatchQueue.main.async {
            container.setNeedsLayout()
        }
    }
}
