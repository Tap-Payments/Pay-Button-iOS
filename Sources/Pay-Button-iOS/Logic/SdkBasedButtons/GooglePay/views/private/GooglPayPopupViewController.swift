//
//  GooglPayPopupViewController.swift
//  
//
//  Created by Osama Rabie on 02/11/2023.
//

import UIKit
import WebKit
import SharedDataModels_iOS


class GooglPayPopupViewController: UIViewController {
    /// The web view used to render the google pay page
    var webView: WKWebView?
    /// A custom action block to execute when nothing else being loaded for a while
    var redirectionReached:(String)->() = { _ in }
    /// The google pay url
    var googlePayUrl:String = ""
    /// A custom action block to execute when the user cancels the payment (back button)
    var googlePayCanceled:()->() = {}
    /// The powered by tap view
    var poweredByTapView:PoweredByTapView = .init(frame: .zero)
    /// Represents the locale needed to render the powered by tap view with
    var selectedLocale:String = "en" {
        didSet{
            self.poweredByTapView.selectedLocale = selectedLocale
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //MARK: - Private methods
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        themeController()
        themeWebView()
        webViewConstraints()
        poweredByTapViewConstraints()
        poweredByTapView.backButtonClicked = {
            self.googlePayCanceled()
        }
    }
    
    
    /// Starts loading the urls
    func startLoading() {
        commonInit()
        self.webView?.load(URLRequest(url: URL(string: self.googlePayUrl)!))
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}



// MARK: - UI & Constraints
extension GooglPayPopupViewController {
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

// MARK: - WebView delegate
extension GooglPayPopupViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // Check if it is the return url
        print("3ds:\(navigationAction.request.url?.absoluteString ?? "")")
        if let requestURL:URL = navigationAction.request.url,
           requestURL.absoluteString.lowercased().hasPrefix(PayButtonTypeEnum.GooglePay.baseUrl().lowercased()) {
            // The web sdk only needs the query string
            self.redirectionReached(requestURL.absoluteString)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
    
    func triggeringValue(from url:URL, with triggeringKeyword:String) -> String? {
        return tap_extractDataFromUrl(url,for:triggeringKeyword, shouldBase64Decode: false)
    }
}

