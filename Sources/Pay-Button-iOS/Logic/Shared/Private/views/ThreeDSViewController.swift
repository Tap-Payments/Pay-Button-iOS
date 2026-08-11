
import UIKit
import WebKit
import SharedDataModels_iOS

class ThreeDSView: UIViewController {

    /// The web view used to render the 3ds page
    var webView: WKWebView?
    /// The details containitng both threeds and redirect urls
    var redirectionData:Redirection = .init()
    /// The timer used to check if no redirection is being called for the last 3 seconds
    var timer: Timer?
    /// The delay that we should wait for to decide if it is idle in  seonds
    var delayTime:CGFloat = 1.000
    /// A custom action block to execute when nothing else being loaded for a while
    var idleForWhile:()->() = {}
    /// A custom action block to execute when nothing else being loaded for a while
    var redirectionReached:(String)->() = { _ in }
    /// A custom action block to execute when the user cancels the authentication
    var threeDSCanceled:()->() = {}
    /// The powered by tap view
    var poweredByTapView:PoweredByTapView = .init(frame: .zero)
    /// The redirect url scheme
    var redirectUrl:String?
    /// Set for the card based buttons only. The card web sdk names the query parameter it wants us to
    /// watch for, ex `auth_payer`, instead of relying on the shared redirection keyword. When it is set
    /// the whole url is handed back rather than only its query string, which is what the card sdk expects.
    var cardRedirectionKeyword:String?
    /// Represents the locale needed to render the powered by tap view with
    var selectedLocale:String = "en" {
        didSet{
            self.poweredByTapView.selectedLocale = selectedLocale
        }
    }
    var popupWebView: WKWebView?
    var closePopupImageView:UIImageView = .init(frame: .init(x: 16, y: 16, width: 32, height: 32))
    
    //MARK: - Init methods
    override func viewDidLoad() {
        super.viewDidLoad()
        //commonInit()
    }
    
    //MARK: - Private methods
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        themeController()
        themeWebView()
        webViewConstraints()
        poweredByTapViewConstraints()
        poweredByTapView.backButtonClicked = {
            self.threeDSCanceled()
        }
    }
    
    
    /// Starts loading the urls
    func startLoading() {
        commonInit()
        webView?.load(URLRequest(url: URL(string: redirectionData.url!)!))
    }
}


// MARK: - UI & Constraints
extension ThreeDSView {
    /// Applies theme on controller level
    func themeController() {
        view.backgroundColor = .clear
    }
    
    /// Applies theme on web view level
    func themeWebView() {
        // Set the needed preferences
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences

        
        // Let us theme the web view
        webView = .init(frame: .zero, configuration: configuration)
        webView?.isOpaque = false
        webView?.backgroundColor = UIColor.white
        webView?.scrollView.backgroundColor = UIColor.clear
        webView?.scrollView.bounces = false
        webView?.layer.cornerRadius = 0
        webView?.clipsToBounds = true
        
        // Let set the delegates
        webView?.scrollView.delegate = self
        webView?.navigationDelegate = self
        webView?.uiDelegate = self
    }
    /// Applies constrains to correctly size and position the web view
    func webViewConstraints() {
        view.addSubview(webView!)
        webView?.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            webView!.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            webView!.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            // The powered by tap bar sits at the very top and overlaps the page by 12, so start right under it
            webView!.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 44),
            webView!.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 40)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        DispatchQueue.main.async {
            self.webView?.setNeedsLayout()
            self.webView?.updateConstraints()
            self.view.setNeedsLayout()
        }
    }
    
    
    /// Applies constrains to correctly size and position the web view
    func poweredByTapViewConstraints() {
        view.addSubview(poweredByTapView)
        view.sendSubviewToBack(poweredByTapView)
        poweredByTapView.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            poweredByTapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            poweredByTapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            poweredByTapView.heightAnchor.constraint(equalToConstant: 56),
            // Anchored to the top of the sheet. Hanging it off the web view instead left the 56 above it
            // empty, and the controller's view is clear, so the app behind showed through as a white band
            poweredByTapView.topAnchor.constraint(equalTo: self.view.topAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        DispatchQueue.main.async {
            self.poweredByTapView.setNeedsLayout()
            self.poweredByTapView.updateConstraints()
            self.view.setNeedsLayout()
        }
    }
}

// MARK: - ScrollView delegate
extension ThreeDSView: UIScrollViewDelegate {
    /// Prevents auto zoom when focusing a field in the web view
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
}
// MARK: - WebView delegate
extension ThreeDSView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // Check if it is the return url
        print("3ds:\(navigationAction.request.url?.absoluteString ?? "")")
        
        DispatchQueue.main.async {
            self.closePopupImageView.removeFromSuperview()
        }
        
        if (navigationAction.request.url?.absoluteString.lowercased() ?? "").contains("apps.apple") {
            let historySize = webView.backForwardList.backList.count
                let firstItem = webView.backForwardList.item(at: -historySize)

                // go to it!
                //webView.go(to: firstItem!)
        }else if let requestURL:URL = navigationAction.request.url,
                 let cardRedirectionKeyword:String = cardRedirectionKeyword,
                 !tap_extractDataFromUrl(requestURL, for: cardRedirectionKeyword, shouldBase64Decode: false).isEmpty {
            // The card sdk wants the whole url back, it reads the result out of it itself
            self.redirectionReached(requestURL.absoluteString)
            decisionHandler(.cancel)
            return
        }else if let requestURL:URL = navigationAction.request.url,
           cardRedirectionKeyword == nil,
           requestURL.absoluteString.lowercased().contains(UrlBasedUtils.redirectionKeyWord.lowercased()) {
            // The web sdk only needs the query string
            // MARK: GooglePay redirect
            /*if redirectUrl == PayButtonTypeEnum.GooglePay.baseUrl() {
                self.redirectionReached(requestURL.absoluteString)
                
            }else{*/
                self.redirectionReached(NSURL(string: requestURL.absoluteString)?.query ??  requestURL.absoluteString)
                
            //}
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let timer = timer {
            timer.invalidate()
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: delayTime, repeats: false, block: { (timer) in
            timer.invalidate()
            self.idleForWhile()
        })
    }
    
    
    
    func triggeringValue(from url:URL, with triggeringKeyword:String) -> String? {
        return tap_extractDataFromUrl(url,for:triggeringKeyword, shouldBase64Decode: false)
    }
}


extension ThreeDSView: WKUIDelegate {
    //MARK: Creating new webView for popup
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        popupWebView = WKWebView(frame: view.bounds, configuration: configuration)
        popupWebView!.tap_allowInspectionInDebugBuilds()
        popupWebView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        popupWebView!.navigationDelegate = self
        popupWebView!.uiDelegate = self
        
        closePopupImageView = .init(frame: .init(x: 16, y: 16, width: 32, height: 32))
        closePopupImageView.removeFromSuperview()
        closePopupImageView.image = UIImage(named: "Close",in: Bundle.currentBundle, with: nil)
        closePopupImageView.tintColor = .white
        closePopupImageView.contentMode = .scaleAspectFit
        
        let closeCareemPayPopupGesture = UITapGestureRecognizer(target: self, action: #selector(self.closeCareemPayPopup(recognizer:)))
        
        closeCareemPayPopupGesture.numberOfTapsRequired = 1

        closePopupImageView.isUserInteractionEnabled = true
        closePopupImageView.addGestureRecognizer(closeCareemPayPopupGesture)
        
        
        view.addSubview(popupWebView!)
        view.addSubview(closePopupImageView)
        
        return popupWebView!
    }
    
    /// Will close the careempay popup
    @objc func closeCareemPayPopup(recognizer : UITapGestureRecognizer)
    {
        DispatchQueue.main.async {
            self.closePopupImageView.removeFromSuperview()
            self.popupWebView?.removeFromSuperview()
        }
    }
    
    //MARK: To close popup
    func webViewDidClose(_ webView: WKWebView) {
        if webView == popupWebView {
            popupWebView?.removeFromSuperview()
            popupWebView = nil
        }
    }
}
