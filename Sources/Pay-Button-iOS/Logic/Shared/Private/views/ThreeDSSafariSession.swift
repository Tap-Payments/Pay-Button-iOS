//
//  ThreeDSSafariSession.swift
//  Pay-Button-iOS
//
//  The same 3DS/ACS challenge as `ThreeDSAuthSession`, run in `SFSafariViewController`
//  instead of `ASWebAuthenticationSession`.
//
//  The reason to reach for this one is visibility. `ASWebAuthenticationSession` reports
//  nothing between opening and the final callback, while this reports the redirects of
//  the initial load and tells us when that load finished. Passkeys work in both, it is
//  a real Safari either way.
//
//  What it costs is the callback. Safari can not hand a custom scheme back to us the way
//  `ASWebAuthenticationSession` does, iOS opens it as a url instead, so the host app has
//  to forward it through `PayButtonView.handleThreeDSCallback(url:)` and the scheme has
//  to be declared in the app's Info.plist.
//

import Foundation
import UIKit
import SafariServices

/// Runs the 3ds authentication inside `SFSafariViewController`, reporting the redirects
/// it can see along the way. Reports its outcome through `ThreeDSAuthSessionDelegate`,
/// the same protocol the `ASWebAuthenticationSession` path uses
final class ThreeDSSafariSession: NSObject {

    /// Notified as the process moves along. Held weakly, the owner keeps the session alive
    weak var delegate: ThreeDSSafariSessionDelegate?

    /// The presented browser, held for the lifetime of the authentication
    private var safari: SFSafariViewController?
    /// The https url the callback has to be mapped back onto
    private var redirectUrl: String?
    /// The scheme the return page bounces to, matched against whatever the app forwards us
    private var callbackScheme: String?
    /// Set once an outcome has been reported, so a dismissal that follows a success is not
    /// mistaken for the payer walking away
    private var hasReported: Bool = false

    /// Starts the authentication process
    /// - Parameter threeDsUrl: The ACS page to load
    /// - Parameter redirectUrl: The https return url, used to rebuild what the card web sdk
    /// expects when the callback comes back through a custom scheme
    /// - Parameter callbackScheme: The scheme the return page bounces to, ex `tapcardsdk`
    /// - Parameter presenter: The view controller to present the browser from
    func start(threeDsUrl: String?,
               redirectUrl: String?,
               callbackScheme: String?,
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
        self.callbackScheme = callbackScheme

        // Safari can not take an https callback back for us, that is exactly what Associated Domains
        // buys ASWebAuthenticationSession. With no scheme to watch for, nothing could ever complete
        guard let callbackScheme = callbackScheme, !callbackScheme.isEmpty else {
            NSLog("ThreeDSSafariSession: no callback scheme to wait for")
            NSLog("ThreeDSSafariSession: this presentation needs PayButtonView.threeDSCallback set to .scheme(\"tapcardsdk\"), an .https callback only works with authenticationSession")
            report(.failure(ThreeDSAuthSessionError.httpsCallbackUnavailable))
            return
        }

        NSLog("ThreeDSSafariSession: starting")
        NSLog("ThreeDSSafariSession: three ds url \(url.absoluteString)")
        NSLog("ThreeDSSafariSession: redirect url \(redirectUrl ?? "nil, the callback will be handed over as it arrives")")
        NSLog("ThreeDSSafariSession: waiting for \(callbackScheme ?? "no"):// to be forwarded from the app")

        let configuration: SFSafariViewController.Configuration = .init()
        configuration.entersReaderIfAvailable = false

        let controller: SFSafariViewController = .init(url: url, configuration: configuration)
        controller.delegate = self
        controller.dismissButtonStyle = .cancel
        safari = controller

        NSLog("ThreeDSSafariSession: presenting the browser")
        presenter.present(controller, animated: true)
    }

    /// Hands the session the url the app was opened with. Called by `PayButtonView`
    /// - Parameter url: The url iOS opened the app with
    /// - Returns: True when the url was the callback this session was waiting for
    @discardableResult
    func handleCallback(url: URL) -> Bool {
        let scheme: String = url.scheme?.lowercased() ?? ""
        guard !scheme.isEmpty, scheme == (callbackScheme?.lowercased() ?? "") else {
            NSLog("ThreeDSSafariSession: ignoring \(url.absoluteString), it is not the callback we wait for")
            return false
        }

        NSLog("ThreeDSSafariSession: the app was opened with the callback")
        ThreeDSSafariSession.printCallback(url)

        // Take the browser down before reporting, the payer is done with it
        dismissBrowser {
            self.report(.success(url))
        }
        return true
    }

    /// Prints the callback url taken apart, so what the acs sent back is readable
    /// - Parameter url: The callback url as it arrived
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
                let redirectionUrl: String = ThreeDSAuthSession.restoreRedirection(from: callbackUrl,
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

    /// Every redirect the first navigation goes through. Once the payer touches the page
    /// this stops firing, safari reports nothing about navigations they cause themselves
    func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL) {
        NSLog("ThreeDSSafariSession: redirect \(URL.absoluteString)")

        // The return page may bounce straight through without the payer doing anything, ex when
        // the issuer decides no challenge is needed, in which case the callback lands here
        if let scheme: String = URL.scheme?.lowercased(), scheme == (callbackScheme?.lowercased() ?? "") {
            NSLog("ThreeDSSafariSession: that redirect is the callback")
            handleCallback(url: URL)
        }
    }

    /// The acs page itself finished loading, everything after this is the payer's doing
    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        NSLog("ThreeDSSafariSession: the acs page loaded \(didLoadSuccessfully ? "successfully" : "and failed")")
        if !didLoadSuccessfully {
            NSLog("ThreeDSSafariSession: no redirects will be reported from here, the load failed")
        }
    }

    /// The payer closed the browser. Harmless once a callback already arrived, `report` ignores it
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        NSLog("ThreeDSSafariSession: the payer closed the browser")
        safari = nil
        report(.failure(ThreeDSAuthSessionError.canceledByUser))
    }
}

/// Reports the progress of a 3ds process running in `SFSafariViewController`
protocol ThreeDSSafariSessionDelegate: AnyObject {
    /// A redirect the initial load went through, or the callback itself
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
