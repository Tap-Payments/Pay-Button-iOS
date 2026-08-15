//
//  ThreeDSSafariSession.swift
//  Pay-Button-iOS
//
//  Runs the 3DS/ACS challenge in `SFSafariViewController`, which unlike `WKWebView` exposes
//  `navigator.credentials` and can therefore serve a passkey.
//
//  Safari hands an app exactly one url, through `initialLoadDidRedirectTo`, and Apple is
//  precise about when: every redirect the page performs *without user interaction*, which
//  carries on after the initial load has completed. The run home from a finished passkey is
//  a chain of those, so this is where the authentication is caught.
//
//  The payer closing the browser is the other ending. Safari never says what page it was on,
//  so that one is answered from what this authentication was given rather than from safari.
//

import Foundation
import UIKit
import SafariServices

/// Runs the 3ds authentication inside `SFSafariViewController`, watching the redirects safari
/// reports for the return url. Reports its outcome through `ThreeDSSafariSessionDelegate`
final class ThreeDSSafariSession: NSObject {

    /// Notified as the process moves along. Held weakly, the owner keeps the session alive
    weak var delegate: ThreeDSSafariSessionDelegate?

    /// The presented browser, held for the lifetime of the authentication
    private var safari: SFSafariViewController?
    /// The https return url, the one redirect worth stopping on
    private var redirectUrl: String?
    /// The query key the card form watches for, ex `auth_payer`
    private var keyword: String?
    /// The identifier the acs page carries in its own path, ex `auth_payer_sSMda29...`
    private var authenticationIdentifier: String?
    /// Set once an outcome has been reported, so a dismissal that follows a success is not
    /// mistaken for the payer walking away
    private var hasReported: Bool = false

    /// Starts the authentication process
    /// - Parameter threeDsUrl: The ACS page to load
    /// - Parameter redirectUrl: The https return url, the redirect that ends the authentication
    /// - Parameter keyword: The query key the card form watches for, ex `auth_payer`
    /// - Parameter presenter: The view controller to present the browser from
    func start(threeDsUrl: String?,
               redirectUrl: String?,
               keyword: String?,
               from presenter: UIViewController?) {

        guard let threeDsUrlString: String = threeDsUrl,
              let url: URL = URL(string: threeDsUrlString) else {
            NSLog("ThreeDSSafariSession: could not parse the three ds url \(threeDsUrl ?? "nil")")
            report(.failure(ThreeDSSessionError.invalidThreeDSUrl))
            return
        }

        guard let presenter: UIViewController = presenter ?? UIApplication.shared.topViewController() else {
            NSLog("ThreeDSSafariSession: no view controller to present from")
            report(.failure(ThreeDSSessionError.failedToStart))
            return
        }

        self.redirectUrl = redirectUrl
        // The acs names the authentication in the last part of its own path
        self.authenticationIdentifier = url.pathComponents.last
        // `auth_payer_sneBZ46...` is the keyword and the id joined, so the keyword can be read back
        // out of it when no redirection details arrived to tell us
        self.keyword = keyword ?? ThreeDSSafariSession.keyword(from: self.authenticationIdentifier)

        // The return url is the only thing this session can recognise. Without one there is nothing
        // to watch the redirects for, and the payer closing the browser becomes the only ending
        guard redirectUrl != nil else {
            NSLog("ThreeDSSafariSession: no return url to watch for, there is nothing to recognise")
            NSLog("ThreeDSSafariSession: set PayButtonView.threeDSCallback to .https(host:path:) naming the return url")
            report(.failure(ThreeDSSessionError.returnUrlUnavailable))
            return
        }

        NSLog("ThreeDSSafariSession: starting")
        NSLog("ThreeDSSafariSession: three ds url \(url.absoluteString)")
        NSLog("ThreeDSSafariSession: watching the redirects for \(redirectUrl ?? "nil")")

        let configuration: SFSafariViewController.Configuration = .init()
        configuration.entersReaderIfAvailable = false

        let controller: SFSafariViewController = .init(url: url, configuration: configuration)
        controller.delegate = self
        controller.dismissButtonStyle = .cancel
        safari = controller

        NSLog("ThreeDSSafariSession: presenting the browser")
        presenter.present(controller, animated: true)
    }

    /// Reads the query key back out of an acs identifier, ex `auth_payer_sneBZ46...` gives
    /// `auth_payer`. The last underscore separated part is the id itself
    /// - Parameter identifier: The identifier the acs carries in its path
    /// - Returns: The keyword, or nil when the identifier has no underscore to split on
    internal static func keyword(from identifier: String?) -> String? {
        guard let identifier = identifier else { return nil }
        let parts: [Substring] = identifier.split(separator: "_")
        guard parts.count > 1 else { return nil }
        return parts.dropLast().joined(separator: "_")
    }

    /// Prints the url taken apart, so what the acs answered with is readable
    /// - Parameter url: The url the authentication came back on
    internal static func printReturnUrl(_ url: URL) {
        NSLog("ThreeDSSafariSession: return url \(url.absoluteString)")
        let components: URLComponents? = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems: [URLQueryItem] = components?.queryItems ?? []
        if queryItems.isEmpty {
            NSLog("ThreeDSSafariSession: it carries no query, the acs answered with nothing")
        } else {
            for item in queryItems {
                NSLog("ThreeDSSafariSession:     \(item.name) = \(item.value ?? "")")
            }
        }
    }

    /// Dismisses the browser if it is still on screen, without notifying the delegate
    func cancel() {
        NSLog("ThreeDSSafariSession: dismissed from the sdk side, the delegate is not told")
        hasReported = true
        dismissBrowser(then: {})
    }

    //MARK: - Private methods

    /// Takes the browser off screen, then runs the block.
    ///
    /// Two things make this less obvious than it looks. `dismiss` sent to a view controller takes
    /// down whatever *it* is presenting first, and only asks its presenter when it is presenting
    /// nothing .. a browser showing a sheet of its own would swallow the call and stay up. And a
    /// dismissal asked for while the presentation is still animating is dropped by uikit, so the
    /// completion runs, the delegate is told, and the browser is still on screen
    /// - Parameter block: Run once the browser is off screen, or straight away if there is none
    private func dismissBrowser(then block: @escaping () -> Void) {
        let onMain: (@escaping () -> Void) -> Void = { work in
            if Thread.isMainThread { work() } else { DispatchQueue.main.async(execute: work) }
        }

        onMain { [weak self] in
            guard let self = self, let browser: SFSafariViewController = self.safari else {
                NSLog("ThreeDSSafariSession: no browser to take down")
                block()
                return
            }
            self.safari = nil

            let takeDown: () -> Void = {
                // Ask the presenter, not the browser, so a browser presenting something of its own
                // does not take that down instead of itself
                guard let presenter: UIViewController = browser.presentingViewController else {
                    NSLog("ThreeDSSafariSession: the browser is not presented by anything, nothing to take down")
                    block()
                    return
                }
                NSLog("ThreeDSSafariSession: taking the browser down")
                presenter.dismiss(animated: true) {
                    if browser.view.window != nil {
                        NSLog("ThreeDSSafariSession: the browser is still on screen after being dismissed")
                    }
                    block()
                }
            }

            // Still animating on or off screen, so wait for that to settle before asking
            if let coordinator = browser.transitionCoordinator {
                NSLog("ThreeDSSafariSession: the browser is mid transition, waiting for it to settle")
                coordinator.animate(alongsideTransition: nil) { _ in takeDown() }
            } else {
                takeDown()
            }
        }
    }

    /// Fans the outcome out to the delegate, always on the main thread and only once
    private func report(_ result: Result<URL, Error>) {
        guard !hasReported else {
            NSLog("ThreeDSSafariSession: an outcome was already reported, ignoring this one")
            return
        }
        hasReported = true

        let deliver: () -> Void = { [weak self] in
            guard let self = self else { return }
            switch result {
            case .success(let returnUrl):
                NSLog("ThreeDSSafariSession: the authentication came home on \(returnUrl.absoluteString)")
                NSLog("ThreeDSSafariSession: -> delegate threeDSSafariSession(didReachReturnUrl:)")
                self.delegate?.threeDSSafariSession(self, didReachReturnUrl: returnUrl)
                let redirectionUrl: String = returnUrl.absoluteString
                NSLog("ThreeDSSafariSession: handing the card form \(redirectionUrl)")
                NSLog("ThreeDSSafariSession: -> delegate threeDSSafariSession(didSucceedWith:)")
                self.delegate?.threeDSSafariSession(self, didSucceedWith: redirectionUrl)
            case .failure(let error):
                if case ThreeDSSessionError.canceledByUser = error {
                    NSLog("ThreeDSSafariSession: -> delegate threeDSSafariSessionDidCancel()")
                    self.delegate?.threeDSSafariSessionDidCancel(self)
                } else {
                    NSLog("ThreeDSSafariSession: reporting a failure \(error)")
                    NSLog("ThreeDSSafariSession: -> delegate threeDSSafariSession(didFailWith:)")
                    self.delegate?.threeDSSafariSession(self, didFailWith: error)
                }
            }
            if self.delegate == nil {
                NSLog("ThreeDSSafariSession: nobody is listening, the delegate is nil")
            }
        }

        if Thread.isMainThread {
            deliver()
        } else {
            DispatchQueue.main.async(execute: deliver)
        }
    }
}

// MARK: - The redirects safari is willing to show us
extension ThreeDSSafariSession: SFSafariViewControllerDelegate {

    /// Every redirect the page performs without the payer causing it, which Apple documents as
    /// carrying on after the initial load has completed. The run home from a finished passkey is
    /// exactly that, a chain of automatic redirects, so the return url lands here
    func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL) {
        NSLog("ThreeDSSafariSession: redirect \(URL.absoluteString)")

        guard isReturnUrl(URL) else { return }

        // Landing on the return url is not the same as being answered. The configured return url is
        // often the bare root of a host, and anything the acs passes through on its way out matches
        // that .. the launcher page navigating, an error page, the payer being sent back untouched.
        // What separates a real return from all of those is the acs naming the authentication in the
        // query, so a match that says nothing is watched rather than taken
        guard carriesAnAnswer(URL) else {
            NSLog("ThreeDSSafariSession: that redirect is the return url but carries no query, so it answers nothing")
            NSLog("ThreeDSSafariSession: staying open, the payer has not been sent back with a result yet")
            return
        }

        NSLog("ThreeDSSafariSession: that redirect is the return url, the authentication is home")
        ThreeDSSafariSession.printReturnUrl(URL)
        dismissBrowser {
            self.report(.success(URL))
        }
    }

    /// Whether the url is the https return url this authentication was given, host and path only.
    /// The query is compared separately, by `carriesAnAnswer`
    /// - Parameter url: A url safari redirected to
    private func isReturnUrl(_ url: URL) -> Bool {
        guard let redirectUrl: String = redirectUrl,
              let expected: URLComponents = URLComponents(string: redirectUrl),
              let expectedHost: String = expected.host?.lowercased(),
              let host: String = url.host?.lowercased(),
              url.scheme?.lowercased() == "https" else { return false }

        let expectedPath: String = expected.path.isEmpty ? "/" : expected.path
        let path: String = url.path.isEmpty ? "/" : url.path
        return host == expectedHost && path == expectedPath
    }

    /// Whether the url names an authentication for the card form to look up, ie whether the acs put
    /// anything in the query at all
    /// - Parameter url: A url that already matched the return url
    private func carriesAnAnswer(_ url: URL) -> Bool {
        return !(URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []).isEmpty
    }

    /// The acs page itself finished loading. Redirects can still be reported after this, as long as
    /// the page performs them itself
    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        NSLog("ThreeDSSafariSession: the acs page loaded \(didLoadSuccessfully ? "successfully" : "and failed")")
        if !didLoadSuccessfully {
            NSLog("ThreeDSSafariSession: no redirects will be reported from here, the load failed")
        }
    }

    /// The payer closed the browser. Harmless once the return url already arrived, `report` ignores it
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        NSLog("ThreeDSSafariSession: the payer closed the browser")
        safari = nil

        // Safari never tells us what page it was on, so a payer who authenticated and a payer who
        // gave up look identical from here. When we can work out the return url ourselves, hand it
        // over and let the backend be the one to say whether the authentication actually passed
        if PayButtonView.threeDSAssumesReturnOnDismiss, let assumed: URL = assumedReturnUrl() {
            NSLog("ThreeDSSafariSession: safari does not say where it ended up, assuming the return url")
            NSLog("ThreeDSSafariSession: the backend decides whether this authentication passed, not us")
            ThreeDSSafariSession.printReturnUrl(assumed)
            report(.success(assumed))
            return
        }

        report(.failure(ThreeDSSessionError.canceledByUser))
    }

    /// Rebuilds the url the acs would have landed on, from the return url this authentication was
    /// given, the keyword the card form watches for, and the identifier the acs carries in its path
    /// - Returns: The return url, or nil when there is not enough to build one
    private func assumedReturnUrl() -> URL? {
        guard let redirectUrl: String = redirectUrl,
              var components: URLComponents = URLComponents(string: redirectUrl),
              let keyword: String = keyword, !keyword.isEmpty,
              let identifier: String = authenticationIdentifier, !identifier.isEmpty else {
            return nil
        }
        components.queryItems = [URLQueryItem(name: keyword, value: identifier)]
        return components.url
    }
}

/// Reports the progress of a 3ds process running in `SFSafariViewController`
protocol ThreeDSSafariSessionDelegate: AnyObject {
    /// The return url the authentication came home on, before it reaches the card form
    func threeDSSafariSession(_ session: ThreeDSSafariSession, didReachReturnUrl returnUrl: URL)
    /// The process completed, carrying the redirection url the card web sdk expects
    func threeDSSafariSession(_ session: ThreeDSSafariSession, didSucceedWith redirectionUrl: String)
    /// The payer closed the browser before finishing
    func threeDSSafariSessionDidCancel(_ session: ThreeDSSafariSession)
    /// The process could not be completed
    func threeDSSafariSession(_ session: ThreeDSSafariSession, didFailWith error: Error)
}

// Only the outcome has to be adopted
extension ThreeDSSafariSessionDelegate {
    func threeDSSafariSession(_ session: ThreeDSSafariSession, didReachReturnUrl returnUrl: URL) {}
}
