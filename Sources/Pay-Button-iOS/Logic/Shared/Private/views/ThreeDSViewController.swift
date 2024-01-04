
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
    /// Should only return the query part of the redirection or not
    var queryOnly:Bool = true
    /// Represents the locale needed to render the powered by tap view with
    var selectedLocale:String = "en" {
        didSet{
            self.poweredByTapView.selectedLocale = selectedLocale
        }
    }
    
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
        
    }
    /// Applies constrains to correctly size and position the web view
    func webViewConstraints() {
        view.addSubview(webView!)
        webView?.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            webView!.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            webView!.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            webView!.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100),
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
            poweredByTapView.bottomAnchor.constraint(equalTo: self.webView!.topAnchor, constant: 12)
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
        if let requestURL:URL = navigationAction.request.url,
           let redirectUrl:String = redirectUrl?.lowercased(),
           requestURL.absoluteString.lowercased().hasPrefix(redirectUrl) {
            // The web sdk only needs the query string
            if redirectUrl == PayButtonTypeEnum.GooglePay.baseUrl() {
                self.redirectionReached(requestURL.absoluteString)
                
            }else{
                self.redirectionReached(queryOnly ? NSURL(string: requestURL.absoluteString)?.query ??  requestURL.absoluteString : requestURL.absoluteString)
                
            }
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
