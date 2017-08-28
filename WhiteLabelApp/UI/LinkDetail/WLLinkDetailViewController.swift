//
//  WLLinkDetailViewController.swift
//  WhiteLabelApp
//
//  Created by Taras Serbin on 7/26/17.
//  Copyright © 2017 Taras Serbin. All rights reserved.
//

import UIKit
import AMScrollingNavbar

class WLLinkDetailViewController: UIViewController {
    
    var dataObjectIdetifier = ""
    var link:WLLink!
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let link = WLCoreDataManager.shared.getNews(identifier: dataObjectIdetifier) as! WLLink
        webView.loadRequest(URLRequest(url: URL(string:link.link!)!))
        webView.delegate = self
        if let navigationController = navigationController as? ScrollingNavigationController {
            navigationController.followScrollView(webView.scrollView, delay: 50.0)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func btnBackTapped(_ sender: Any) {
        let _ =  self.navigationController?.popViewController(animated: true)
    }    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension WLLinkDetailViewController:UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        activityView.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        activityView.isHidden = false
        activityIndicator.startAnimating()
    }
}

