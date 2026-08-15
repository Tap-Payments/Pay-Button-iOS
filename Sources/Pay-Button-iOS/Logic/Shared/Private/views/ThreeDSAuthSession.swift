//
//  ThreeDSAuthSession.swift
//  Pay-Button-iOS
//
//  Ported from Card-iOS, the card form behind the button is the same web sdk so the
//  passkey problem and its answer are identical.
//
//  Presents the 3DS/ACS challenge in the system browser so the page can use
//  WebAuthn / passkeys. `WKWebView` does not expose `navigator.credentials`
//  unless the host app carries the restricted browser entitlement, therefore
//  any issuer that serves a FIDO challenge has to be handled here instead of
//  in `ThreeDSView`.
//

import Foundation
import UIKit
import AuthenticationServices

/// Describes how the system browser hands control back to the sdk once the
/// authentication process is done.
public enum ThreeDSCallback {
    /// A custom scheme, e.g. `tapcardsdk`. The scheme does **not** need to be
    /// registered in the host app's Info.plist, the session intercepts it
    /// internally. Requires the page served at the https return url to bounce
    /// to `<scheme>://...` carrying the same query string.
    case scheme(String)
    /// An https return url matched through Associated Domains. Requires the
    /// host app to declare `webcredentials:<host>` and the domain to serve a
    /// matching `apple-app-site-association`. iOS 17.4 and later only.
    case https(host: String, path: String)

    /// The custom scheme this callback waits on, nil for an https one. The safari presentation
    /// needs it to recognise the url the app is opened with
    var scheme: String? {
        switch self {
        case .scheme(let scheme): return scheme
        case .https: return nil
        }
    }

    /// The https return url this callback describes, nil for a scheme one. Used as the return url
    /// when a passkey arrives as a bare navigation and no redirection details came with it
    var httpsReturnUrl: String? {
        switch self {
        case .scheme: return nil
        case .https(let host, let path): return "https://\(host)\(path)"
        }
    }
}

/// Errors surfaced while running the 3ds process inside the system browser
enum ThreeDSAuthSessionError: Error {
    /// The payer dismissed the browser before finishing the authentication
    case canceledByUser
    /// The session could not be started, e.g. no window to present from
    case failedToStart
    /// `.https` callback was requested on a version of iOS that cannot serve it
    case httpsCallbackUnavailable
    /// The ACS page url could not be parsed
    case invalidThreeDSUrl
}

/// Reports the progress of a 3ds process running in the system browser.
///
/// Note that `ASWebAuthenticationSession` is a closed box, it reports nothing
/// while the payer is on the ACS page. `didReachRedirect` therefore fires for
/// the return url only, not for the redirects the ACS performs on its way there.
/// Tracking those needs the embedded `ThreeDSView` path instead.
protocol ThreeDSAuthSessionDelegate: AnyObject {
    /// The browser is on screen and the ACS page is loading
    func threeDSAuthSessionDidStart(_ session: ThreeDSAuthSession)
    /// The browser handed control back, carrying the raw callback url exactly as
    /// it was received, before it is mapped onto the https redirection url
    func threeDSAuthSession(_ session: ThreeDSAuthSession, didReachRedirect callbackUrl: URL)
    /// The process completed, carrying the redirection url the card web sdk expects
    func threeDSAuthSession(_ session: ThreeDSAuthSession, didSucceedWith redirectionUrl: String)
    /// The payer dismissed the browser before finishing
    func threeDSAuthSessionDidCancel(_ session: ThreeDSAuthSession)
    /// The process could not be completed
    func threeDSAuthSession(_ session: ThreeDSAuthSession, didFailWith error: Error)
}

// Everything but the outcome is optional to adopt
extension ThreeDSAuthSessionDelegate {
    func threeDSAuthSessionDidStart(_ session: ThreeDSAuthSession) {}
    func threeDSAuthSession(_ session: ThreeDSAuthSession, didReachRedirect callbackUrl: URL) {}
}

/// Runs the 3ds authentication inside `ASWebAuthenticationSession`, which has
/// the same web platform feature set as Safari and therefore supports passkeys.
final class ThreeDSAuthSession: NSObject {

    /// Notified as the process moves along. Held weakly, the owner keeps the session alive
    weak var delegate: ThreeDSAuthSessionDelegate?

    /// Held onto for the lifetime of the authentication, releasing it early
    /// dismisses the browser
    private var session: ASWebAuthenticationSession?
    /// The window the browser is presented from
    private weak var anchor: UIWindow?
    /// The https url the callback has to be mapped back onto
    private var redirectUrl: String?

    /// Starts the authentication process
    /// - Parameter threeDsUrl: The ACS page to load
    /// - Parameter redirectUrl: The https return url from the redirection details, used
    /// to rebuild what the card web sdk expects when we come back through a custom scheme
    /// - Parameter callback: How the browser hands control back to the sdk
    /// - Parameter ephemeral: When true the browser runs as a private session, which
    /// suppresses the system consent alert at the cost of not sharing Safari's cookies
    /// - Parameter window: The window to present the browser from
    func start(threeDsUrl: String?,
               redirectUrl: String?,
               callback: ThreeDSCallback,
               ephemeral: Bool,
               in window: UIWindow?) {

        // The caller only proves the string is there, it still has to parse as a url
        guard let threeDsUrlString: String = threeDsUrl,
              let url: URL = URL(string: threeDsUrlString) else {
            report(.failure(ThreeDSAuthSessionError.invalidThreeDSUrl))
            return
        }

        anchor = window
        self.redirectUrl = redirectUrl

        let handler: (URL?, Error?) -> Void = { [weak self] url, error in
            guard let self = self else { return }
            // The session is single use, let go of it either way
            self.session = nil
            if let url = url {
                self.report(.success(url))
            } else if let error = error as? ASWebAuthenticationSessionError,
                      error.code == .canceledLogin {
                self.report(.failure(ThreeDSAuthSessionError.canceledByUser))
            } else {
                self.report(.failure(error ?? ThreeDSAuthSessionError.failedToStart))
            }
        }

        let created: ASWebAuthenticationSession
        switch callback {
        case .scheme(let scheme):
            created = ASWebAuthenticationSession(url: url,
                                                 callbackURLScheme: scheme,
                                                 completionHandler: handler)
        case .https(let host, let path):
            guard #available(iOS 17.4, *) else {
                NSLog("ThreeDSAuthSession: an https callback needs iOS 17.4, this device can not serve it")
                report(.failure(ThreeDSAuthSessionError.httpsCallbackUnavailable))
                return
            }
            NSLog("ThreeDSAuthSession: waiting for the callback on https://\(host)\(path)")
            NSLog("ThreeDSAuthSession: that needs webcredentials:\(host) in Associated Domains and an apple-app-site-association naming this app")
            let httpsCallback: ASWebAuthenticationSession.Callback = .https(host: host, path: path)
            // The return url has to match the callback or the session waits forever, so say up front
            // whether the shape the acs comes back with would be accepted
            if let sample: URL = URL(string: "https://\(host)\(path)?auth_payer=sample") {
                NSLog("ThreeDSAuthSession: \(sample.absoluteString) would match: \(httpsCallback.matchesURL(sample))")
            }
            created = ASWebAuthenticationSession(url: url,
                                                 callback: httpsCallback,
                                                 completionHandler: handler)
        }

        created.presentationContextProvider = self
        // A private session drops the "<app> wants to use <domain> to sign in"
        // consent alert, leaving the payer with just the ACS page. It costs the
        // shared Safari cookie jar, so the issuer cannot honour "remember this
        // device". Passkeys are unaffected either way, they come from the platform
        // authenticator rather than from cookies
        created.prefersEphemeralWebBrowserSession = ephemeral

        session = created

        NSLog("ThreeDSAuthSession: anchor \(window == nil ? "not supplied by the button, falling back to the app's key window" : "supplied by the button")")
        if #available(iOS 13.4, *) {
            NSLog("ThreeDSAuthSession: canStart \(created.canStart)")
        } else {
            // Fallback on earlier versions
        }

        guard created.start() else {
            // With an https callback this is what a missing association looks like. The session
            // refuses rather than opening a browser it could never get a callback from
            NSLog("ThreeDSAuthSession: the browser refused to start")
            NSLog("ThreeDSAuthSession: with an https callback that usually means webcredentials is not provisioned for this build, or the host serves no apple-app-site-association. Fall back to .scheme(\"tapcardsdk\") until it is")
            session = nil
            report(.failure(ThreeDSAuthSessionError.failedToStart))
            return
        }

        onMain { [weak self] in
            guard let self = self else { return }
            self.delegate?.threeDSAuthSessionDidStart(self)
        }
    }

    /// Dismisses the browser if it is still on screen, without notifying the delegate
    func cancel() {
        session?.cancel()
        session = nil
    }

    //MARK: - Private methods

    /// Fans the outcome out to the delegate, always on the main thread
    private func report(_ result: Result<URL, Error>) {
        onMain { [weak self] in
            guard let self = self else { return }
            switch result {
            case .success(let callbackUrl):
                self.delegate?.threeDSAuthSession(self, didReachRedirect: callbackUrl)
                let redirectionUrl: String = ThreeDSAuthSession.restoreRedirection(from: callbackUrl,
                                                                                  using: self.redirectUrl)
                self.delegate?.threeDSAuthSession(self, didSucceedWith: redirectionUrl)
            case .failure(let error):
                if case ThreeDSAuthSessionError.canceledByUser = error {
                    self.delegate?.threeDSAuthSessionDidCancel(self)
                } else {
                    self.delegate?.threeDSAuthSession(self, didFailWith: error)
                }
            }
        }
    }

    /// Hops onto the main thread only when we are not already on it
    private func onMain(_ block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async(execute: block)
        }
    }
}

// MARK: - Callback mapping
extension ThreeDSAuthSession {
    /// Maps a custom scheme callback url back onto the https redirection url the card
    /// web sdk is expecting, keeping the query and fragment the ACS sent us
    /// - Parameter callbackUrl: The url the system browser came back with
    /// - Parameter redirectUrl: The https redirection url from the redirection details
    /// - Returns: The url to hand over to the web sdk
    internal static func restoreRedirection(from callbackUrl: URL, using redirectUrl: String?) -> String {
        // An https callback is already what the web sdk wants
        let scheme: String = callbackUrl.scheme?.lowercased() ?? ""
        guard scheme != "http", scheme != "https" else { return callbackUrl.absoluteString }

        guard let redirectUrl: String = redirectUrl,
              var components: URLComponents = URLComponents(string: redirectUrl) else {
            return callbackUrl.absoluteString
        }

        let callbackComponents: URLComponents? = URLComponents(url: callbackUrl, resolvingAgainstBaseURL: false)
        components.percentEncodedQuery = callbackComponents?.percentEncodedQuery
        components.percentEncodedFragment = callbackComponents?.percentEncodedFragment

        return components.url?.absoluteString ?? callbackUrl.absoluteString
    }
}

// MARK: - Presentation anchor
extension ThreeDSAuthSession: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        if let anchor: UIWindow = anchor {
            NSLog("ThreeDSAuthSession: presenting from the button's own window")
            return anchor
        }
        // The button had no window, ex it was asked for a passkey while off screen. Returning a
        // fresh ASPresentationAnchor here hands the session an empty window that was never on
        // screen, and nothing appears, so go and find the one the app is actually showing
        if let keyWindow: UIWindow = ThreeDSAuthSession.foregroundKeyWindow() {
            NSLog("ThreeDSAuthSession: the button had no window, presenting from the app's key window")
            return keyWindow
        }
        NSLog("ThreeDSAuthSession: no window anywhere, the browser will not be able to present")
        return ASPresentationAnchor()
    }

    /// The window the app is currently showing, or nil when there is none
    internal static func foregroundKeyWindow() -> UIWindow? {
        let scenes: [UIWindowScene] = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let active: UIWindowScene? = scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
        return active?.windows.first { $0.isKeyWindow } ?? active?.windows.first
    }
}
