
import UIKit
import WebKit
import SharedDataModels_iOS

/// The custom view that provides an interface for the  knet button
internal class RedirectionPayButton: PayButtonBaseView {
    /// The web view used to render the knet button
    internal var webView: WKWebView = .init()
    /// keeps a hold of the loaded web sdk configurations url
    internal var currentlyLoadedConfigurations:URL?
    // This means we are ok to start the authentication process
    internal var threeDsView:ThreeDSView?
    
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
        currentlyLoadedConfigurations = url
        // instruct the web view to load the needed url
        let request = URLRequest(url: url!)
        
        
        webView.navigationDelegate = self
        webView.load(request)
    }
    
    /// used to setup the constraint of the Tap card sdk view
    private func setupWebView() {
        // Creates needed configuration for the web view
        let config = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: config)
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
        let buttonHeight = self.heightAnchor.constraint(greaterThanOrEqualToConstant: 48)
        // SWIPE let buttonHeight = self.heightAnchor.constraint(greaterThanOrEqualToConstant: 48)
        
        // Activate the constraints
        NSLayoutConstraint.activate([left, right, top, bottom, buttonHeight])
        webView.layoutIfNeeded()
        webView.updateConstraints()
        self.layoutIfNeeded()
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
        //let operatorModel:Operator = .init(publicKey: configDict["publicKey"] as? String ?? "", metadata: generateApplicationHeader())
        var updatedConfigurations:[String:Any] = configDict
        
        
        do {
            currentlyLoadedConfigurations = try URL(string:UrlBasedUtils.generatePayButtonSdkURL(from: updatedConfigurations, payButtonType: payButtonType)) ?? nil
            updatedConfigurations["headers"] = UrlBasedUtils.generateApplicationHeader(headersEncryptionPublicKey: currentlyLoadedConfigurations?.headersEncryptionPublicKey() ?? "")
            updatedConfigurations["redirect"] = ["url":payButtonType.tapRedirectionSchemeUrl()]
            try openUrl(url: URL(string: UrlBasedUtils.generatePayButtonSdkURL(from: updatedConfigurations, payButtonType: payButtonType)))
        }
        catch {
            self.delegate?.onError?(data: "{error:\(error.localizedDescription)}")
        }
    }
}
