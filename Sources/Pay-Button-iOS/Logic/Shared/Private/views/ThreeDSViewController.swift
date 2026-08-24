
import UIKit
import WebKit
import SharedDataModels_iOS

/// The 3ds/redirection page, shown as a `SwiftEntryKit` entry over the button's own screen rather
/// than presented as a separate view controller .. a `UIView` for the same reason Card-iOS's own
/// `ThreeDSView` is one, `SwiftEntryKit.display(entry:using:)` takes the view directly
class ThreeDSView: UIView {

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
    override init(frame: CGRect) {
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
        themeController()
        themeWebView()
        TapBrowserChrome.install(webView: webView!, bar: poweredByTapView, in: self)
        poweredByTapView.backButtonClicked = {
            self.threeDSCanceled()
        }
    }


    /// Starts loading the urls
    func startLoading() {
        webView?.load(URLRequest(url: URL(string: redirectionData.url!)!))
    }
}


// MARK: - UI & Constraints
extension ThreeDSView {
    /// Applies theme on controller level
    func themeController() {
        TapBrowserChrome.applyBackground(to: self)
    }

    /// Applies theme on web view level
    func themeWebView() {
        // Set the needed preferences
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.tap_disableZoom()


        // Let us theme the web view
        webView = .init(frame: .zero, configuration: configuration)
        TapBrowserChrome.style(webView!)

        // Let set the delegates
        webView?.scrollView.delegate = self
        webView?.navigationDelegate = self
        webView?.uiDelegate = self
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
        popupWebView = WKWebView(frame: bounds, configuration: configuration)
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


        addSubview(popupWebView!)
        addSubview(closePopupImageView)

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
