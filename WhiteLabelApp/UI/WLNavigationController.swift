//
//  WLNavigationController.swift
//  WhiteLabelApp
//
//  Created by Taras Serbin on 4/25/17.
//  Copyright © 2017 Taras Serbin. All rights reserved.
//

import UIKit
import ChameleonFramework
class WLNavigationController: UINavigationController {
    
    // MARK: - Lifecycle
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        if let theme =  WLCoreDataManager.shared.getBrand(identifier: BRAND_ID)?.theme {
            navigationBar.tintColor = UIColor.init(hexString: theme.titleColor!)
            navigationBar.barTintColor = UIColor.init(hexString: theme.bodyColor!)
            self.navigationController?.navigationBar.titleTextAttributes = [
                NSForegroundColorAttributeName : UIColor.init(hexString: theme.titleColor!)!
            ]
        }
        navigationBar.backItem?.title = ""
        // This needs to be in here, not in init
        interactivePopGestureRecognizer?.delegate = self
    }
    
    deinit {
        delegate = nil
        interactivePopGestureRecognizer?.delegate = nil
    }
    
    // MARK: - Overrides
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        duringPushAnimation = true
        
        super.pushViewController(viewController, animated: animated)
    }
    
    // MARK: - Private Properties
    
    fileprivate var duringPushAnimation = false
    
    // MARK: - Unsupported Initializers
    
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
}

// MARK: - UINavigationControllerDelegate

extension WLNavigationController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let swipeNavigationController = navigationController as? WLNavigationController else { return }
        swipeNavigationController.duringPushAnimation = false
    }
    
}

// MARK: - UIGestureRecognizerDelegate

extension WLNavigationController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == interactivePopGestureRecognizer else {
            return true // default value
        }
        
        // Disable pop gesture in two situations:
        // 1) when the pop animation is in progress
        // 2) when user swipes quickly a couple of times and animations don't have time to be performed
        return viewControllers.count > 1 && duringPushAnimation == false
    }
}

