//
//  PayButtonSdk+Scanner.swift
//  Pay-Button-iOS
//
//  The card form asks for the camera, the sdk answers with one.
//
//  Ported from Card-iOS, which runs the same card form and answers the same event the same way,
//  except that it makes the integrator pass a controller to present from and this finds its own.
//

import Foundation
import UIKit
import AVFoundation
import SharedDataModels_iOS

/// Runs the card scanner the card form asks for
extension PayButtonSdk {

    /// Asks for the camera and shows the scanner once it is granted.
    ///
    /// The host app has to carry `NSCameraUsageDescription`, there is no way for a framework to
    /// declare it on its behalf, and ios ends the app rather than the request without it
    internal func scanCard() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            guard let self = self else { return }

            guard granted else {
                NSLog("PayButton: the payer did not allow the camera, there is nothing to scan with")
                DispatchQueue.main.async {
                    self.delegate?.onError?(data: "{\"error\":\"The user didn't approve accessing the camera.\"}")
                }
                return
            }

            DispatchQueue.main.async {
                guard let presenter: UIViewController = UIApplication.shared.topViewController() else {
                    NSLog("PayButton: no view controller to present the scanner from")
                    self.delegate?.onError?(data: "{\"error\":\"Could not present the card scanner.\"}")
                    return
                }

                let scanner: CardScannerViewController = .init()
                scanner.delegate = self
                scanner.modalPresentationStyle = .fullScreen
                self.cardScanner = scanner
                NSLog("PayButton: presenting the card scanner")
                presenter.present(scanner, animated: true)
            }
        }
    }

    /// Types the scanned card into the form.
    ///
    /// The button page wraps the card in an iframe, so `window.CardSDK` is the one that reaches it,
    /// the same way the authentication handover does, with the page's own function as a fallback
    /// - Parameter card: What the scanner read
    internal func fillTheForm(with card: TapCard) {
        let expiry: String = "\(card.tapCardExpiryMonth ?? "")/\(card.tapCardExpiryYear ?? "")"
        let scanned: [String:String] = ["cardNumber": card.tapCardNumber ?? "",
                                        "expiryDate": card.tapCardExpiryMonth == nil ? "" : expiry,
                                        "cvv": card.tapCardCVV ?? "",
                                        "cardHolderName": card.tapCardName ?? ""]

        guard let json: Data = try? JSONSerialization.data(withJSONObject: scanned),
              let arguments: String = String(data: json, encoding: .utf8) else { return }

        let javaScript: String = """
        (function() {
            var scanned = \(arguments);
            if (window.CardSDK && typeof window.CardSDK.fillCardInputs === 'function') {
                window.CardSDK.fillCardInputs(scanned);
                return 'CardSDK';
            }
            if (typeof window.fillCardInputs === 'function') {
                window.fillCardInputs(scanned);
                return 'window';
            }
            return 'none';
        })()
        """

        NSLog("PayButton: filling the form with the scanned card")
        webView.evaluateJavaScript(javaScript) { result, error in
            // `none` means the page has neither function, so the scan has nowhere to go
            NSLog("PayButton: fillCardInputs handled by \(result ?? "nil") \(error?.localizedDescription ?? "")")
        }
    }
}

/// Receives what the scanner read
extension PayButtonSdk: CardScannerViewControllerDelegate {

    /// A card was read, take the camera down and type it in
    func cardScanned(_ card: TapCard, in scanner: CardScannerViewController) {
        cardScanner = nil
        scanner.dismiss(animated: true) { [weak self] in
            self?.fillTheForm(with: card)
        }
    }

    /// The payer closed the scanner without one being read. The form is left as it was
    func cardScannerDidCancel(_ scanner: CardScannerViewController) {
        NSLog("PayButton: the payer closed the scanner")
        cardScanner = nil
    }
}
