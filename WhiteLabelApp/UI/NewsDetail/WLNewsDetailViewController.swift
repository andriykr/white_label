//
//  WLNewsDetailViewController.swift
//  WhiteLabelApp
//
//  Created by Taras Serbin on 4/25/17.
//  Copyright © 2017 Taras Serbin. All rights reserved.
//

import UIKit
import WebKit
import MMMarkdown
import XWebView
class WLNewsDetailViewController: UIViewController {
    
    var dataObjectIdetifier = ""
    var article:WLArticle!
    var image:UIImage?
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnBookmark: UIButton!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var imgArticle: UIImageView!
    @IBOutlet weak var newsContainer: UIView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var cnstHeight:NSLayoutConstraint!
    var webView:WKWebView!
    
    
    lazy var baseURL: URL = {
        return appDelegate.bundle.url(forResource: "index", withExtension: "html")!
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let theme =  WLCoreDataManager.shared.getBarnd(identifier: BRAND_ID)?.theme {
            self.navigationController?.navigationBar.titleTextAttributes = [
                NSForegroundColorAttributeName : UIColor.init(hexString: theme.titleColor!)!
            ]
            view.backgroundColor =  UIColor.init(hexString: theme.bodyBackgroundColor!)!
        }
  
        article = WLCoreDataManager.shared.getArticle(identifier: dataObjectIdetifier)
        let brand = article.brand!.firstObject as! WLBrand
        imgArticle.backgroundColor = UIColor.init(hexString:brand.theme!.cellBackgroundColor!)
        let articleText = article.body!
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "dd MMM YYYY"
        lblDate.text = dateFormatter.string(from: article.date!)
        btnBookmark.isSelected = article.isBookmark
        lblTitle.text = article.headline
        print(articleText)
        do {
            
            
            let preferences = WKPreferences()
            preferences.javaScriptEnabled = true
            let configuration = WKWebViewConfiguration()
            configuration.preferences = preferences
            webView = WKWebView.init(frame: CGRect.zero, configuration:configuration)
//            webView.isUserInteractionEnabled = false
            
            webView.scrollView.delegate = self
            webView.translatesAutoresizingMaskIntoConstraints = false
            webView.scrollView.maximumZoomScale = 1.0
            webView.scrollView.maximumZoomScale = 1.0
            webView.navigationDelegate = self
            for subview in webView.scrollView.subviews {
                
                // iterate over recognizers of subview
                for recognizer in subview.gestureRecognizers ?? [] {
                    
                    // check the recognizer is  a UITapGestureRecognizer
                    if recognizer.isKind(of: UITapGestureRecognizer.self) {
                        
                        // cast the UIGestureRecognizer as UITapGestureRecognizer
                        let tapRecognizer = recognizer as! UITapGestureRecognizer
                        
                        // check if it is a 1-finger double-tap
                        if tapRecognizer.numberOfTapsRequired == 2 && tapRecognizer.numberOfTouchesRequired == 1 {
                            
                            // remove the recognizer
                            subview.removeGestureRecognizer(recognizer)
                        }
                    }
                }
            }
            try loadHTMLView(articleText, view: webView)
            newsContainer.addSubview(webView)
            addObserver(self, forKeyPath: "webView.scrollView.contentSize", options: .new, context: nil)
            let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: .alignAllCenterY, metrics: nil, views: ["view":webView])
            let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: .alignAllCenterX, metrics: nil, views: ["view":webView])
            newsContainer.addConstraints(vConstraints)
            newsContainer.addConstraints(hConstraints)
        } catch (let error) {
            appDelegate.showAlertError(controller: self, title: "Error", message: error.localizedDescription, actions: nil)
        }
        
        imgArticle.image = image
        
        self.navigationController?.isNavigationBarHidden = false
        print(self.navigationItem)
        imgArticle.layer.masksToBounds = true

        view.backgroundColor = .clear
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        webView.scrollView.delegate = nil
        removeObserver(self, forKeyPath: "webView.scrollView.contentSize")
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "webView.scrollView.contentSize" {
            if cnstHeight.constant !=  webView.scrollView.contentSize.height {
                print(webView.scrollView.contentSize.height)
                cnstHeight.constant = webView.scrollView.contentSize.height
                print(webView.scrollView.contentSize.height, cnstHeight.constant)
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func loadHTMLView(_ markdownString: String, view:WKWebView) throws {
        let tempHtml = try MMMarkdown.htmlString(withMarkdown: markdownString, extensions:.gitHubFlavored)
        var pageHTMLString = try htmlFromTemplate(tempHtml)
        pageHTMLString = pageHTMLString.replacingOccurrences(of: "<img src=\"//", with: "<img src=\"https://")
        view.loadHTMLString(pageHTMLString, baseURL: baseURL)
    }
    
    func htmlFromTemplate(_ htmlString: String) throws -> String {
        let template = try String.init(contentsOf: baseURL, encoding: String.Encoding.utf8)
        return template.replacingOccurrences(of: "APP_HTML", with: htmlString)
    }
    
    @IBOutlet weak var btnBookmarkTapped: UIButton!
    @IBAction func btnBookmarkTapped(_ sender: Any) {
        article.isBookmark = !article.isBookmark
        btnBookmark.isSelected = article.isBookmark
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    @IBAction func btnBackTapped(_ sender: UIBarButtonItem) {
        let _ =  self.navigationController?.popViewController(animated: true)
    }
    
     
 
}

extension WLNewsDetailViewController:UIScrollViewDelegate {
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return nil
    }
}

extension WLNewsDetailViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated {
            if let url = navigationAction.request.url {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.openURL(url)
                    decisionHandler(.allow)
                } else {
                    decisionHandler(.cancel)
                    let error = NSError.init(domain: Bundle.main.bundleIdentifier!, code: -1, userInfo: [NSLocalizedDescriptionKey:"Unable to open URL"])
                    appDelegate.showAlertError(controller: self, title: "Error", message: error.localizedDescription, actions: nil)
                }
            } else {
                decisionHandler(.cancel)
                let error = NSError.init(domain: Bundle.main.bundleIdentifier!, code: -1, userInfo: [NSLocalizedDescriptionKey:"Unable to open URL"])
                appDelegate.showAlertError(controller: self, title: "Error", message: error.localizedDescription, actions: nil)
            }
        } else {
            if let url = navigationAction.request.url {
                if url == baseURL {
                    print("not a user click")
                    decisionHandler(.allow)
                }
            }
        }
        decisionHandler(.cancel)
    }
    
//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        insertContentsOfCSSFile(into: webView) // 2
//    }
//    
//    func insertCSSString(into webView: WKWebView) {
//        let cssString = "body { font-size: 50px; color: #f00 }"
//        let jsString = "var style = document.createElement('style'); style.innerHTML = '\(cssString)'; document.head.appendChild(style);"
//        webView.evaluateJavaScript(jsString, completionHandler: nil)
//    }
//    
//    func insertContentsOfCSSFile(into webView: WKWebView) {
//        guard let path = appDelegate.bundle.path(forResource: "down_min", ofType: "css", inDirectory:"css") else { return }
//        let cssString = try! String(contentsOfFile: path).trimmingCharacters(in: .whitespacesAndNewlines)
//        let jsString = "var style = document.createElement('style'); style.innerHTML = '\(cssString)'; document.head.appendChild(style);"
//        webView.evaluateJavaScript(jsString, completionHandler: nil)
//    }
//    
//    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
//        print(error)
//    }
}

