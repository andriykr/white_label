//
//  WLLaunchViewController.swift
//  WhiteLabelApp
//
//  Created by Taras Serbin on 4/21/17.
//  Copyright © 2017 Taras Serbin. All rights reserved.
//

import UIKit
import ReachabilitySwift

class WLLaunchViewController: UIViewController {
    
    var reachability: Reachability?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Start reachability without a hostname intially
        setupReachability(nil, useClosures: true)
        startNotifier()
        
        // After 5 seconds, stop and re-start reachability, this time using a hostname
        let dispatchTime = DispatchTime.now() + DispatchTimeInterval.seconds(5)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            self.stopNotifier()
            self.setupReachability("google.com", useClosures: false)
            self.startNotifier()
            
            let dispatchTime = DispatchTime.now() + DispatchTimeInterval.seconds(5)
            DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                self.stopNotifier()
                self.setupReachability("invalidhost", useClosures: true)
                self.startNotifier()            }
            
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopNotifier()
    }
    func setupReachability(_ hostName: String?, useClosures: Bool) {
        let reachability = hostName == nil ? Reachability() : Reachability(hostname: hostName!)
        self.reachability = reachability
        
        if useClosures {
            
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(WLLaunchViewController.reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: reachability)
        }
    }
    
    func startNotifier() {
        do {
            try reachability?.startNotifier()
        } catch {
            return
        }
    }
    
    func stopNotifier() {
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
        reachability = nil
    }
    
    
    func reachabilityChanged(_ note: Notification) {
        let reachability = note.object as! Reachability
        let appDelegate = UIApplication.shared.delegate as! WLAppDelegate
        if reachability.isReachable {
            if WLCoreDataManager.shared.getBrand(identifier: BRAND_ID)  == nil {
                appDelegate.getBrand()
            }
        }
    }
    
    deinit {
        stopNotifier()
    }
}
