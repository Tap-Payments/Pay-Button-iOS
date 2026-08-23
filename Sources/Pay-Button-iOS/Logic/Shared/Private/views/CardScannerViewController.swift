//
//  CardScannerViewController.swift
//  Pay-Button-iOS
//
//  The camera feed the card form asks for when the payer taps scan.
//
//  Ported from Card-iOS, which shows the same scanner behind the same card form, so a payer who
//  scans a card in one and in the other is looking at the same thing.
//

import UIKit
import AVFoundation
import TapCardScannerWebWrapper_iOS
import TapCardVlidatorKit_iOS
import SharedDataModels_iOS

/// Reports what the scanner read
internal protocol CardScannerViewControllerDelegate: AnyObject {
    /// A card was read off the camera
    /// - Parameter card: What the scanner made of it
    /// - Parameter scanner: The controller that read it, still on screen
    func cardScanned(_ card: TapCard, in scanner: CardScannerViewController)
    /// The payer closed the scanner without one being read
    /// - Parameter scanner: The controller they closed
    func cardScannerDidCancel(_ scanner: CardScannerViewController)
}

/// Shows the camera with the scanner over it, and reports the card it reads
internal class CardScannerViewController: UIViewController {

    /// Notified when a card is read or the payer gives up
    internal weak var delegate: CardScannerViewControllerDelegate?

    /// Does the reading, drawing its own frame and corners over the feed
    private lazy var inlineScanner: TapInlineCardScanner = .init(dataSource: self)
    /// What the feed is drawn into
    private let previewView: UIView = .init(frame: .zero)
    /// The way out, since the scanner draws no chrome of its own
    private let closeButton: UIButton = .init(type: .system)
    /// Set once a card was read, so the dismissal that follows is not reported as giving up
    private var hasScanned: Bool = false

    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupPreview()
        setupCloseButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        inlineScanner.delegate = self
        do {
            // No timeout, the payer decides when to give up
            try inlineScanner.startScanning(in: previewView,
                                            scanningBorderColor: .green,
                                            blurBackground: true,
                                            showTapCorners: true,
                                            timoutAfter: -1)
        } catch {
            NSLog("CardScannerViewController: the scanner could not start, \(error.localizedDescription)")
            close()
        }
    }

    //MARK: - Private methods

    /// Fills the screen with the camera feed
    private func setupPreview() {
        previewView.backgroundColor = .clear
        previewView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(previewView)
        NSLayoutConstraint.activate([
            previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            previewView.topAnchor.constraint(equalTo: view.topAnchor),
            previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    /// The scanner reads a card or it does not, and a payer holding a card it will not read needs a
    /// way out that is not force quitting
    private func setupCloseButton() {
        closeButton.setTitle("✕", for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: 22, weight: .medium)
        closeButton.tintColor = .white
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        closeButton.layer.cornerRadius = 20
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16)
        ])
    }

    @objc private func closeTapped() {
        close()
    }

    /// Takes the scanner off screen and says the payer gave up, unless a card was already read
    private func close() {
        guard !hasScanned else { return }
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.delegate?.cardScannerDidCancel(self)
        }
    }
}

// MARK: - What the scanner reads
extension CardScannerViewController: TapScannerDataSource, TapInlineScannerProtocl {

    /// Every brand, the card form decides what it will take
    func allowedCardBrands() -> [CardBrand] {
        return CardBrand.allCases
    }

    /// A card came off the feed
    func tapCardScannerDidFinish(with tapCard: TapCard) {
        guard !hasScanned else { return }
        hasScanned = true
        NSLog("CardScannerViewController: a card was scanned")
        delegate?.cardScanned(tapCard, in: self)
    }

    /// The wrapper's own dismissal
    func tapFullCardScannerDimissed() {
        close()
    }

    /// Only reachable with a timeout set, which this one has not
    func tapInlineCardScannerTimedOut(for inlineScanner: TapInlineCardScanner) {
        close()
    }
}
