//
//  AppDelegate.swift
//  WhiteLabelApp
//
//  Created by Taras Serbin on 4/18/17.
//  Copyright © 2017 Taras Serbin. All rights reserved.
//

import UIKit
import ContentfulPersistence
import CoreData
import Fabric
import Crashlytics

let BRAND_ID = "4bPiMYV076qKi0okKuY4SY"
@UIApplicationMain
class WLAppDelegate: UIResponder, UIApplicationDelegate {
    
    lazy var bundle: Bundle = {
        let bundle = Bundle.main
        let url = bundle.url(forResource: "WebView", withExtension: "bundle")!
        return Bundle(url: url)!
    }()
    var window: UIWindow?
    var isLoading = false
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateInitialViewController()
        self.window?.rootViewController = vc
        self.window?.makeKeyAndVisible()
        if let brand = WLCoreDataManager.shared.getBrand(identifier: BRAND_ID) {
            applyTheme(theme: brand.theme!)
        } else {
            getBrand()
        }
        Fabric.with([Crashlytics.self])
        
                // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        let queryParameters = [
            "content_type": ArticleContetntTypeID,
            "fields.brand.sys.id": BRAND_ID,
            "include": 2] as [String : Any]
        WLWebApi.shared.getArticles(queryParameters, brand:WLCoreDataManager.shared.getBrand(identifier: BRAND_ID)!) { (articles, error) in
            
        }
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func applyTheme(theme:WLBrandTheme) {
        if let mainVC = window?.rootViewController {
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TopViewController")
            mainVC.present(vc, animated: false, completion: {
                self.window?.rootViewController = vc
            })
            
            
           
        }
    }
    
    func showAlertError(controller:UIViewController, title:String, message:String, actions:[UIAlertAction]?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let actions = actions {
            for action in actions {
                alert.addAction(action)
            }
        } else {
            let action = UIAlertAction.init(title: "OK", style: .default) { (action) in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(action)
        }
        controller.present(alert, animated: true, completion: nil)
    }
    
    func getBrand() {
        WLWebApi.shared.getBrand(identifier: BRAND_ID) { (b, error) in
            if error == nil {
                DispatchQueue.main.async {
                    self.applyTheme(theme: b!.theme!)
                }
            } else {
                DispatchQueue.main.async {
                    WLCoreDataManager.shared.saveContext()
                    if let vc = self.window?.rootViewController {
                        let actionOk = UIAlertAction.init(title: "OK", style: .cancel, handler: nil)
                        self.showAlertError(controller: vc, title: "Error", message: error!.localizedDescription, actions: [actionOk])
                    }
                }
            }
        }
    }
}

