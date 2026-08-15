//
//  ThreeDSReturn.swift
//  Pay-Button-iOS
//
//  What a finished 3ds authentication is expected to come back on, and what can go wrong on
//  the way there. Both belong to `ThreeDSSafariSession`, which is the only thing that runs a
//  passkey now.
//

import Foundation

/// Names the url a finished authentication comes back on.
///
/// The acs is given this as its return url, and the sdk recognises it among the redirects safari
/// reports, which is what ends the authentication and takes the browser down
public enum ThreeDSCallback {
    /// The https return url, ex `https://sdk.dev.tap.company/`. Host and path are what get matched,
    /// the query is where the acs puts its answer so it is never compared
    case https(host: String, path: String)

    /// The return url this describes
    var httpsReturnUrl: String? {
        switch self {
        case .https(let host, let path): return "https://\(host)\(path)"
        }
    }
}

/// Errors surfaced while running the 3ds process in the system browser
enum ThreeDSSessionError: Error {
    /// The payer dismissed the browser before finishing the authentication
    case canceledByUser
    /// The session could not be started, e.g. no view controller to present from
    case failedToStart
    /// No return url was named, so there is nothing for the redirects to be matched against
    case returnUrlUnavailable
    /// The ACS page url could not be parsed
    case invalidThreeDSUrl
}
