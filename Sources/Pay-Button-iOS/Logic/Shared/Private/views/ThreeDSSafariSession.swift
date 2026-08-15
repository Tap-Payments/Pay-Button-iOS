//
//  ThreeDSSafariSession.swift
//  Pay-Button-iOS
//
//  The same 3DS/ACS challenge as `ThreeDSAuthSession`, run in `SFSafariViewController`
//  instead of `ASWebAuthenticationSession`.
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
            report(.failure(ThreeDSAuthSessionError.invalidThreeDSUrl))
            return
        }

        guard let presenter: UIViewController = presenter ?? UIApplication.shared.topViewController() else {
            NSLog("ThreeDSSafariSession: no view controller to present from")
            report(.failure(ThreeDSAuthSessionError.failedToStart))
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
            report(.failure(ThreeDSAuthSessionError.httpsCallbackUnavailable))
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

    /// Prints the url taken apart, so what the acs sent back is readable
    /// - Parameter url: The url the authentication came back on
    internal static func printCallback(_ url: URL) {
        NSLog("ThreeDSSafariSession: callback \(url.absoluteString)")
        let components: URLComponents? = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems: [URLQueryItem] = components?.queryItems ?? []
        if queryItems.isEmpty {
            NSLog("ThreeDSSafariSession: callback carries no query, the acs sent nothing back")
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

    /// Takes the browser off screen, then runs the block
    private func dismissBrowser(then block: @escaping () -> Void) {
        guard let safari = safari else {
            block()
            return
        }
        self.safari = nil
        safari.dismiss(animated: true) {
            block()
        }
    }

    /// Makes sure the url going to the card form actually names this authentication.
    ///
    /// A url that arrives with no query names nothing, and the card form has no id to look up. The
    /// acs can hand one over that way, ex it lands on the bare return url, so rebuild the query out
    /// of the keyword and the identifier this authentication was given whenever it is missing
    /// - Parameter url: The url the authentication came back on
    /// - Returns: The same url when it already answers, the rebuilt one when it does not
    private func answering(_ url: URL) -> URL {
        let carriesNoAnswer: Bool = (URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []).isEmpty
        guard carriesNoAnswer else { return url }

        guard let assumed: URL = assumedReturnUrl() else {
            NSLog("ThreeDSSafariSession: \(url.absoluteString) names no authentication, and there is not enough to rebuild one")
            NSLog("ThreeDSSafariSession: the card form will be handed a url with nothing to look up")
            return url
        }

        NSLog("ThreeDSSafariSession: \(url.absoluteString) carries no query, so it names no authentication")
        NSLog("ThreeDSSafariSession: rebuilding it out of the keyword and the identifier instead")
        return assumed
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
            case .success(let callbackUrl):
                NSLog("ThreeDSSafariSession: redirection reached \(callbackUrl.absoluteString)")
                NSLog("ThreeDSSafariSession: -> delegate threeDSSafariSession(didReachRedirect:)")
                self.delegate?.threeDSSafariSession(self, didReachRedirect: callbackUrl)
                let answered: URL = self.answering(callbackUrl)
                let redirectionUrl: String = ThreeDSAuthSession.restoreRedirection(from: answered,
                                                                                  using: self.redirectUrl)
                NSLog("ThreeDSSafariSession: handing the card form \(redirectionUrl)")
                NSLog("ThreeDSSafariSession: -> delegate threeDSSafariSession(didSucceedWith:)")
                self.delegate?.threeDSSafariSession(self, didSucceedWith: redirectionUrl)
            case .failure(let error):
                if case ThreeDSAuthSessionError.canceledByUser = error {
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

        NSLog("ThreeDSSafariSession: that redirect is the return url, the authentication is home")
        ThreeDSSafariSession.printCallback(URL)
        dismissBrowser {
            self.report(.success(URL))
        }
    }

    /// Whether the url is the https return url this authentication was given, host and path only.
    /// The query is where the acs puts its answer, so it is deliberately not compared
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
            ThreeDSSafariSession.printCallback(assumed)
            report(.success(assumed))
            return
        }

        report(.failure(ThreeDSAuthSessionError.canceledByUser))
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
    /// A redirect the process went through, or the return url itself
    func threeDSSafariSession(_ session: ThreeDSSafariSession, didReachRedirect callbackUrl: URL)
    /// The process completed, carrying the redirection url the card web sdk expects
    func threeDSSafariSession(_ session: ThreeDSSafariSession, didSucceedWith redirectionUrl: String)
    /// The payer closed the browser before finishing
    func threeDSSafariSessionDidCancel(_ session: ThreeDSSafariSession)
    /// The process could not be completed
    func threeDSSafariSession(_ session: ThreeDSSafariSession, didFailWith error: Error)
}

// Only the outcome has to be adopted
extension ThreeDSSafariSessionDelegate {
    func threeDSSafariSession(_ session: ThreeDSSafariSession, didReachRedirect callbackUrl: URL) {}
}
