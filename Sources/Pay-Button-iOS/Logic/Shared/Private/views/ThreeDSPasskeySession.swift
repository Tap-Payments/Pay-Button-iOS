//
//  ThreeDSPasskeySession.swift
//  Pay-Button-iOS
//
//  Runs the 3DS/ACS challenge in `ASWebAuthenticationSession`, which is a real safari and so can
//  serve a passkey, unlike `WKWebView` which has no `navigator.credentials`.
//
//  What it gives over `SFSafariViewController` is the ending. The system watches for the callback
//  scheme itself, closes the browser the moment the page reaches it, and hands the whole url over.
//  Nothing has to be declared in the host app for that .. the scheme never reaches ios, the session
//  claims it internally, so no `CFBundleURLTypes`, no Associated Domains, nothing to forward.
//
//  What it costs is visibility. Nothing at all is reported between opening and the callback, so the
//  return page has to bounce to `tapCardWebSDK://onPasskeyRedirect?data=...` or the session simply
//  waits until the payer gives up.
//

import Foundation
import UIKit
import AuthenticationServices

/// Runs the 3ds authentication in `ASWebAuthenticationSession`, ending on the callback scheme
final class ThreeDSPasskeySession: NSObject {

    /// Notified as the process moves along. Held weakly, the owner keeps the session alive
    weak var delegate: ThreeDSPasskeySessionDelegate?

    /// Held for the lifetime of the authentication, letting go of it early closes the browser
    private var session: ASWebAuthenticationSession?
    /// The window the browser is presented from
    private weak var anchor: UIWindow?
    /// The https return url, used to rebuild what the card form expects when the callback carries
    /// something other than a url of its own
    private var redirectUrl: String?
    /// The query key the card form watches for, ex `auth_payer`
    private var keyword: String?
    /// The identifier the acs page carries in its own path, ex `auth_payer_sSMda29...`
    private var authenticationIdentifier: String?
    /// Set once an outcome has been reported
    private var hasReported: Bool = false

    /// Starts the authentication process
    /// - Parameter threeDsUrl: The ACS page to load
    /// - Parameter redirectUrl: The https return url, used when the callback names no url itself
    /// - Parameter callbackScheme: The scheme the return page bounces to, ex `tapCardWebSDK`,
    /// without the `://`. The session claims it internally, the host app declares nothing
    /// - Parameter keyword: The query key the card form watches for, ex `auth_payer`
    /// - Parameter window: The window to present the browser from
    func start(threeDsUrl: String?,
               redirectUrl: String?,
               callbackScheme: String,
               keyword: String?,
               in window: UIWindow?) {

        guard let threeDsUrlString: String = threeDsUrl,
              let url: URL = URL(string: threeDsUrlString) else {
            NSLog("ThreeDSPasskeySession: could not parse the three ds url \(threeDsUrl ?? "nil")")
            report(.failure(ThreeDSSessionError.invalidThreeDSUrl))
            return
        }

        anchor = window
        self.redirectUrl = redirectUrl
        // The acs names the authentication in the last part of its own path
        self.authenticationIdentifier = url.pathComponents.last
        self.keyword = keyword ?? ThreeDSPasskeySession.keyword(from: self.authenticationIdentifier)

        NSLog("ThreeDSPasskeySession: starting")
        NSLog("ThreeDSPasskeySession: three ds url \(url.absoluteString)")
        NSLog("ThreeDSPasskeySession: waiting for \(callbackScheme)://")
        NSLog("ThreeDSPasskeySession: that scheme is claimed by the session itself, the app declares nothing")

        let created: ASWebAuthenticationSession = .init(url: url,
                                                       callbackURLScheme: callbackScheme) { [weak self] callbackUrl, error in
            guard let self = self else { return }
            // Single use either way, let go of it
            self.session = nil

            if let callbackUrl: URL = callbackUrl {
                NSLog("ThreeDSPasskeySession: the browser came back on \(callbackUrl.absoluteString)")
                self.report(.success(callbackUrl))
            } else if let error = error as? ASWebAuthenticationSessionError, error.code == .canceledLogin {
                NSLog("ThreeDSPasskeySession: the payer closed the browser")
                self.report(.failure(ThreeDSSessionError.canceledByUser))
            } else {
                NSLog("ThreeDSPasskeySession: the browser failed, \(error?.localizedDescription ?? "no reason given")")
                self.report(.failure(error ?? ThreeDSSessionError.failedToStart))
            }
        }

        created.presentationContextProvider = self
        // A private session drops the "<app> wants to use <domain> to sign in" alert at the cost of
        // safari's shared cookies. Passkeys come from the platform authenticator either way
        created.prefersEphemeralWebBrowserSession = PayButtonView.threeDSPrefersEphemeralSession

        session = created

        guard created.start() else {
            NSLog("ThreeDSPasskeySession: the browser refused to start")
            session = nil
            report(.failure(ThreeDSSessionError.failedToStart))
            return
        }
    }

    /// Hands the session a callback that arrived somewhere other than through the browser, ex the
    /// card form navigating to it inside the web view
    /// - Parameter url: The callback url
    /// - Returns: True when the session took it
    @discardableResult
    func handleCallback(url: URL) -> Bool {
        guard !hasReported else { return false }
        NSLog("ThreeDSPasskeySession: a callback arrived outside the browser, \(url.absoluteString)")
        session?.cancel()
        session = nil
        report(.success(url))
        return true
    }

    /// Closes the browser without telling the delegate
    func cancel() {
        NSLog("ThreeDSPasskeySession: closed from the sdk side, the delegate is not told")
        hasReported = true
        session?.cancel()
        session = nil
    }

    /// Reads the query key back out of an acs identifier, ex `auth_payer_sneBZ46...` gives `auth_payer`
    /// - Parameter identifier: The identifier the acs carries in its path
    /// - Returns: The keyword, or nil when the identifier has no underscore to split on
    internal static func keyword(from identifier: String?) -> String? {
        guard let identifier = identifier else { return nil }
        let parts: [Substring] = identifier.split(separator: "_")
        guard parts.count > 1 else { return nil }
        return parts.dropLast().joined(separator: "_")
    }

    //MARK: - Private methods

    /// Works out what to hand the card form out of the callback the browser came back on.
    ///
    /// The return page bounces to `tapCardWebSDK://onPasskeyRedirect?data=...`, and what sits in
    /// `data` decides. A url is handed over as it is, a base64 wrapper is unwrapped first, and
    /// anything else falls back to the return url rebuilt from the id the acs was given
    /// - Parameter callbackUrl: The url the browser came back on
    /// - Returns: The url for `loadAuthentication`
    private func redirectionUrl(from callbackUrl: URL) -> String {
        ThreeDSPasskeySession.printCallback(callbackUrl)

        let components: URLComponents? = URLComponents(url: callbackUrl, resolvingAgainstBaseURL: false)
        let data: String? = components?.queryItems?.first(where: { $0.name == "data" })?.value

        if let data: String = data, !data.isEmpty {
            // The card form sends its data base64 encoded elsewhere, so try that first
            let unwrapped: String = ThreeDSPasskeySession.base64Decoded(data) ?? data
            if unwrapped != data {
                NSLog("ThreeDSPasskeySession: data decoded to \(unwrapped)")
            }
            if let url: URL = URL(string: unwrapped), let scheme = url.scheme?.lowercased(),
               scheme == "http" || scheme == "https" {
                NSLog("ThreeDSPasskeySession: data names the url to finish on")
                return unwrapped
            }
            NSLog("ThreeDSPasskeySession: data is not a url, falling back to the return url we can build")
        } else {
            NSLog("ThreeDSPasskeySession: the callback carries no data")
        }

        if let assumed: URL = assumedReturnUrl() {
            NSLog("ThreeDSPasskeySession: rebuilt \(assumed.absoluteString) out of the keyword and the identifier")
            return assumed.absoluteString
        }

        NSLog("ThreeDSPasskeySession: nothing to build a return url out of, handing the callback over as it is")
        return callbackUrl.absoluteString
    }

    /// Rebuilds the url the acs would have landed on, out of the return url, the keyword the card
    /// form watches for and the identifier the acs carries in its path
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

    /// Decodes a base64 string, or nil when it is not one
    private static func base64Decoded(_ value: String) -> String? {
        // Url safe base64 travels in query strings, so put it back before decoding
        var padded: String = value
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        if padded.count % 4 != 0 {
            padded += String(repeating: "=", count: 4 - padded.count % 4)
        }
        guard let data: Data = Data(base64Encoded: padded),
              let decoded: String = String(data: data, encoding: .utf8) else { return nil }
        return decoded
    }

    /// Prints the callback taken apart, so what the return page sent back is readable
    internal static func printCallback(_ url: URL) {
        NSLog("ThreeDSPasskeySession: callback \(url.absoluteString)")
        NSLog("ThreeDSPasskeySession: callback names \(url.host ?? "nothing")")
        let queryItems: [URLQueryItem] = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        if queryItems.isEmpty {
            NSLog("ThreeDSPasskeySession: the callback carries no query")
        } else {
            for item in queryItems {
                NSLog("ThreeDSPasskeySession:     \(item.name) = \(item.value ?? "")")
            }
        }
    }

    /// Fans the outcome out to the delegate, always on the main thread and only once
    private func report(_ result: Result<URL, Error>) {
        guard !hasReported else {
            NSLog("ThreeDSPasskeySession: an outcome was already reported, ignoring this one")
            return
        }
        hasReported = true

        let deliver: () -> Void = { [weak self] in
            guard let self = self else { return }
            switch result {
            case .success(let callbackUrl):
                self.delegate?.threeDSPasskeySession(self, didReachCallback: callbackUrl)
                let redirectionUrl: String = self.redirectionUrl(from: callbackUrl)
                NSLog("ThreeDSPasskeySession: handing the card form \(redirectionUrl)")
                self.delegate?.threeDSPasskeySession(self, didSucceedWith: redirectionUrl)
            case .failure(let error):
                if case ThreeDSSessionError.canceledByUser = error {
                    self.delegate?.threeDSPasskeySessionDidCancel(self)
                } else {
                    self.delegate?.threeDSPasskeySession(self, didFailWith: error)
                }
            }
            if self.delegate == nil {
                NSLog("ThreeDSPasskeySession: nobody is listening, the delegate is nil")
            }
        }

        if Thread.isMainThread { deliver() } else { DispatchQueue.main.async(execute: deliver) }
    }
}

// MARK: - Where the browser is presented from
extension ThreeDSPasskeySession: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        if let anchor: UIWindow = anchor {
            return anchor
        }
        // The button had no window of its own, ex it was asked for a passkey while off screen. A
        // fresh anchor here is a window that was never on screen and nothing would appear
        if let keyWindow: UIWindow = ThreeDSPasskeySession.foregroundKeyWindow() {
            NSLog("ThreeDSPasskeySession: the button had no window, presenting from the app's key window")
            return keyWindow
        }
        NSLog("ThreeDSPasskeySession: no window anywhere, the browser can not present")
        return ASPresentationAnchor()
    }

    /// The window the app is currently showing, or nil when there is none
    internal static func foregroundKeyWindow() -> UIWindow? {
        let scenes: [UIWindowScene] = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let active: UIWindowScene? = scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
        return active?.windows.first { $0.isKeyWindow } ?? active?.windows.first
    }
}

/// Reports the progress of a 3ds process running in `ASWebAuthenticationSession`
protocol ThreeDSPasskeySessionDelegate: AnyObject {
    /// The callback url exactly as it arrived, before anything is read out of it
    func threeDSPasskeySession(_ session: ThreeDSPasskeySession, didReachCallback callbackUrl: URL)
    /// The process completed, carrying the url the card web sdk expects
    func threeDSPasskeySession(_ session: ThreeDSPasskeySession, didSucceedWith redirectionUrl: String)
    /// The payer closed the browser before finishing
    func threeDSPasskeySessionDidCancel(_ session: ThreeDSPasskeySession)
    /// The process could not be completed
    func threeDSPasskeySession(_ session: ThreeDSPasskeySession, didFailWith error: Error)
}

// Only the outcome has to be adopted
extension ThreeDSPasskeySessionDelegate {
    func threeDSPasskeySession(_ session: ThreeDSPasskeySession, didReachCallback callbackUrl: URL) {}
}
