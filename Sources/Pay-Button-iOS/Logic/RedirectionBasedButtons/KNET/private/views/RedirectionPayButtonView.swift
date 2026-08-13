
import UIKit
import WebKit
import SharedDataModels_iOS

/// The custom view that provides an interface for the  knet button
internal class RedirectionPayButton: PayButtonBaseView {
    /// The web view used to render the knet button
    internal var webView: WKWebView = .init()
    /// keeps a hold of the loaded web sdk configurations url
    internal var currentlyLoadedConfigurations:[String:Any]?
    /// The view that will present full screen 3ds flow
    internal var threeDsView:ThreeDSView?
    /// Holds the window the card form opened with `window.open`, ex the click to pay identity flow,
    /// so it can be dismissed again once the page closes it
    internal var popupViewController:PayButtonPopupViewController?
    /// Runs a passkey authentication in the system browser. Held for the lifetime of the process,
    /// letting go of it early dismisses the browser
    internal var threeDSAuthSession:ThreeDSAuthSession?
    /// The last redirection the card form announced, kept for its return url. A passkey challenge
    /// that arrives as a plain navigation carries no details of its own
    internal var lastCardRedirection:CardRedirection?
    /// The minimum height a pay button is allowed to take
    internal static let minimumButtonHeight:CGFloat = 48
    /// Kept around so the card based buttons (click to pay) can grow the view while the customer fills the form
    internal var heightConstraint:NSLayoutConstraint?
    /// The card form reports a burst of heights while it lays itself out, one point apart.
    /// Animating each of them stacks a new animation on top of a running one and the button jitters,
    /// so wait for the burst to settle and animate once to the height it landed on.
    private static let heightSettleDelay:TimeInterval = 0.05
    /// How long the button takes to grow or shrink to a new height
    private static let heightAnimationDuration:TimeInterval = 0.25
    /// The height the last burst asked for
    private var pendingHeight:CGFloat?
    /// The height currently applied, a repeated value is not worth an animation
    private var appliedHeight:CGFloat = 0
    /// The first sizing snaps. Growing from the 48pt placeholder looks like a glitch rather than a transition
    private var hasSizedOnce:Bool = false
    /// Lets a new report cancel the one that has not fired yet
    private var heightSettleWorkItem:DispatchWorkItem?
    
    //MARK: - Init methods
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    //MARK: - Private methods
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        // Setuo the web view contais the web sdk
        setupWebView()
        // setup the constraint to put each view in its correct positiob
        setupConstraints()
    }
    
    /// Updates the button to the correct type.
    internal func updateType(to payButtonType:PayButtonTypeEnum) {
        self.payButtonType = payButtonType
    }
    
    /// Used to open a url inside the Tap card web sdk.
    /// - Parameter url: The url needed to load.
    internal func openUrl(url: URL?) {
        // Store it for further usages
        // instruct the web view to load the needed url
        let request = URLRequest(url: url!)
        
        
        webView.navigationDelegate = self
        webView.load(request)
    }
    
    /// used to setup the constraint of the Tap card sdk view
    private func setupWebView() {
        // Creates needed configuration for the web view
        let config = WKWebViewConfiguration()
        // Click to pay runs its identity flow in a window the card form opens with `window.open`,
        // so let the page open one and take the callback that hands it to us
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true
        config.preferences = preferences
        webView = WKWebView(frame: .zero, configuration: config)
        webView.uiDelegate = self
        webView.tap_allowInspectionInDebugBuilds()
        // Let us make sure it is of a clear background and opaque, not to interfer with the merchant's app background
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        webView.scrollView.backgroundColor = UIColor.clear
        webView.scrollView.bounces = false
        webView.isHidden = false
        // Let us add it to the view
        self.backgroundColor = .clear
        self.addSubview(webView)
    }
    
    /// Setup Constaraints for the sub views.
    private func setupConstraints() {
        // Preprocessing needed setup
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        // Define the web view constraints
        let top  = webView.topAnchor.constraint(equalTo: self.topAnchor)
        let left = webView.leftAnchor.constraint(equalTo: self.leftAnchor)
        let right = webView.rightAnchor.constraint(equalTo: self.rightAnchor)
        let bottom = webView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        let buttonHeight = self.heightAnchor.constraint(greaterThanOrEqualToConstant: RedirectionPayButton.minimumButtonHeight)
        heightConstraint = buttonHeight
        // SWIPE let buttonHeight = self.heightAnchor.constraint(greaterThanOrEqualToConstant: 48)

        // Activate the constraints
        NSLayoutConstraint.activate([left, right, top, bottom, buttonHeight])
        webView.layoutIfNeeded()
        webView.updateConstraints()
        self.layoutIfNeeded()
    }

    /// Grows or shrinks the button to the height the web sdk asks for.
    /// The card based buttons (click to pay) render a form that resizes while the customer types.
    ///
    /// Reports arrive in bursts, so the last one of a burst wins and only that one is animated.
    /// The delegate is told once the burst settled too, so the merchant animates once as well.
    /// - Parameter to height: The height in points the web sdk reported
    internal func updateHeight(to height:CGFloat) {
        DispatchQueue.main.async {
            self.pendingHeight = max(RedirectionPayButton.minimumButtonHeight, height)
            // Let the newest report replace the one still waiting to fire
            self.heightSettleWorkItem?.cancel()
            let settleWorkItem:DispatchWorkItem = .init { [weak self] in
                self?.applyPendingHeight()
            }
            self.heightSettleWorkItem = settleWorkItem
            DispatchQueue.main.asyncAfter(deadline: .now() + RedirectionPayButton.heightSettleDelay, execute: settleWorkItem)
        }
    }

    /// Applies the height the burst settled on
    private func applyPendingHeight() {
        guard let targetHeight = pendingHeight,
              let heightConstraint = heightConstraint,
              targetHeight != appliedHeight else { return }
        appliedHeight = targetHeight
        heightConstraint.constant = targetHeight

        // The very first sizing has nothing to animate from
        guard hasSizedOnce else {
            hasSizedOnce = true
            superview?.layoutIfNeeded()
            layoutIfNeeded()
            delegate?.onHeightChange?(height: Double(targetHeight))
            return
        }

        // beginFromCurrentState picks up from wherever a running animation got to,
        // instead of snapping back to the old height and starting over
        UIView.animate(withDuration: RedirectionPayButton.heightAnimationDuration,
                       delay: 0,
                       options: [.beginFromCurrentState, .curveEaseOut, .allowUserInteraction]) {
            self.superview?.layoutIfNeeded()
            self.layoutIfNeeded()
        }
        delegate?.onHeightChange?(height: Double(targetHeight))
    }
    
    
    /// Tells the web sdk the process is finished with the data from backend
    /// - Parameter rediectionUrl: The url with the needed data coming from back end at the end of the currently running process
    internal func passRedirectionDataToSDK(rediectionUrl:String) {
        // The web sdk wants the query parameters only
        webView.evaluateJavaScript("window.retrieve('\(rediectionUrl)')")
        //generateTapToken()
    }
    
    
    ///  configures the knet button with the needed configurations for it to work
    ///  - Parameter config: The configurations dctionary. Recommended, as it will make you able to customly add models without updating
    ///  - Parameter delegate:A protocol that allows integrators to get notified from events fired from knet button
    override
    internal func initPayButton(configDict: [String : Any], delegate: PayButtonDelegate? = nil) {
        self.delegate = delegate
        // Let us render the button
        DispatchQueue.main.async {
            self.openUrl(url: URL(string: UrlBasedUtils.buttonWrapperUrl)!)
        }
        
        /*do {
            //currentlyLoadedConfigurations = try URL(string:UrlBasedUtils.generatePayButtonSdkURL(from: updatedConfigurations, payButtonType: payButtonType)) ?? nil
            updatedConfigurations["headers"] = UrlBasedUtils.generateApplicationHeader(headersEncryptionPublicKey: updatedConfigurations.headersEncryptionPublicKey() ?? "")
            updatedConfigurations["redirect"] = ["url":payButtonType.tapRedirectionSchemeUrl()]
            currentlyLoadedConfigurations = updatedConfigurations
            
            try UrlBasedUtils.generatePayButtonSdkURL(from: updatedConfigurations, payButtonType: payButtonType) { buttonUrl, error in
                DispatchQueue.main.async {
                    // Check error
                    if error.isEmpty {
                        self.openUrl(url: URL(string: buttonUrl)!)
                    }else{
                        self.delegate?.onError?(data: "{error:\(error)}")
                    }
                }
            }
        }
        catch {
            self.delegate?.onError?(data: "{error:\(error.localizedDescription)}")
        }*/
    }
}
