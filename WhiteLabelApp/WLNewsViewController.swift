//
//  ViewController.swift
//  WhiteLabelApp
//
//  Created by Taras Serbin on 4/18/17.
//  Copyright © 2017 Taras Serbin. All rights reserved.
//

import UIKit
import ChameleonFramework
import CoreData
import ESPullToRefresh
import SafariServices

class WLNewsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityView: UIView!
    lazy var dataManager: WLCoreDataManager = {
        return WLCoreDataManager.shared
    }()
    
    lazy var dataSource:WLDataSource = {
        let resultsController = try! self.dataManager.fetchedResultsController(forContentType: WLNews.self, predicate: self.predicate, sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)], sectionName:self.sectionName)
        return WLDataSource(fetchedResultsController: resultsController, tableView: self.tableView)
    }()
    

    var predicate: NSPredicate = NSPredicate.init(value: true)
    var sectionName = "sectionName"
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    func refresh() {
        activityView.isHidden = false
        activityIndicator.startAnimating()
        let refresh = {
            self.activityView.isHidden = true
            self.activityIndicator.stopAnimating()
            try self.dataSource.performFetch()
            NotificationCenter.default.addObserver(self, selector: #selector(WLNewsViewController.refresh), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        }
        
        if PreferenceManager.shared.lastDate != nil {
            let dateFormater = DateFormatter.init()
            dateFormater.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            dateFormater.timeZone = TimeZone.init(abbreviation: "UTC")
            let queryParameters = [
                "content_type": ArticleContetntTypeID,
                "fields.brand.sys.id": BRAND_ID,
                "sys.updatedAt[gt]": dateFormater.string(from: PreferenceManager.shared.lastDate!),
                "order": "sys.updatedAt",
                "include": 2] as [String : Any]
            WLWebApi.shared.getLastDate(queryParameters) { (date, error) in
                if error == nil {
                    if let resultDate = date, let ldate = PreferenceManager.shared.lastDate {
                        print(resultDate, ldate)
                        if resultDate != ldate {
                            self.dataManager.performSynchronization { (result, error) in
                                DispatchQueue.main.async {
                                    WLCoreDataManager.shared.saveContext()
                                    if result {
                                        do {
                                            try refresh()
                                         
                                        } catch {}
                                    } else {
                                        let actionOk = UIAlertAction.init(title: "OK", style: .cancel, handler: nil)
                                        appDelegate.showAlertError(controller: self, title: "Error", message: error!.localizedDescription, actions: [actionOk])
                                    }
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                do {
                                    try refresh()
                                } catch {}
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        let actionOk = UIAlertAction.init(title: "OK", style: .cancel, handler: nil)
                        appDelegate.showAlertError(controller: self, title: "Error", message: error!.localizedDescription, actions: [actionOk])
                        do {
                            try refresh()
                        } catch {}
                    }
                    
                }
            }

        } else {
            self.dataManager.performSynchronization { (result, error) in
                DispatchQueue.main.async {
                    WLCoreDataManager.shared.saveContext()
                    if result {
                        do {
                            try refresh()
                        } catch {}
                    } else {
                        let actionOk = UIAlertAction.init(title: "OK", style: .cancel, handler: nil)
                        appDelegate.showAlertError(controller: self, title: "Error", message: error!.localizedDescription, actions: [actionOk])
                    }
                }
            }
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if let theme =  WLCoreDataManager.shared.getBrand(identifier: BRAND_ID)?.theme {
            self.navigationController?.navigationBar.titleTextAttributes = [
                NSForegroundColorAttributeName : UIColor.init(hexString: theme.titleColor!)!
            ]
            view.backgroundColor =  UIColor.init(hexString: theme.bodyBackgroundColor!)!
        }
        
        tableView.register(UINib.init(nibName: "WLFullScreenImageCell", bundle: nil), forCellReuseIdentifier:  "WLFullScreenImageCell")
        tableView.register(UINib.init(nibName: "WLYesterdayNewsCell", bundle: nil), forCellReuseIdentifier:  "WLYesterdayNewsCell")
        tableView.register(UINib.init(nibName: "WLTableHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "WLTableHeaderView")
        tableView.register(UINib.init(nibName: "WLTodayNewsCell", bundle: nil), forCellReuseIdentifier: "WLTodayNewsCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.sectionHeaderHeight = 0
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        refresh()
        self.tableView.es_addPullToRefresh {
            [weak self] in
            self?.refresh()
            self?.tableView.es_stopPullToRefresh(ignoreDate: true)
            /// Set ignore footer or not
            self?.tableView.es_stopPullToRefresh(ignoreDate: true, ignoreFooter: false)
        }

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewsDetailSegue" {
            if let vc = segue.destination as? WLNewsDetailViewController, let cell = sender as? CellConfigurable {
                vc.dataObjectIdetifier = cell.dataObjectIdentifier
                vc.image = cell.imageArticle
            }
        } else {
            if let vc = segue.destination as? WLLinkDetailViewController, let cell = sender as? CellConfigurable {
                vc.dataObjectIdetifier = cell.dataObjectIdentifier
            }
        }
    }

}

extension WLNewsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.fetchedResultsController.sections?.count ?? 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         if dataSource.fetchedResultsController.sections![indexPath.section].name.isEmpty {
            let cell:UITableViewCell
            let dataObject = dataSource.fetchedResultsController.object(at: indexPath) as! WLNews
            if dataObject is WLArticle {
                if (dataObject as! WLArticle).articleLayout?.layoutType?.name == fullScreenLayoutName {
                    cell = tableView.dequeueReusableCell(withIdentifier: "WLFullScreenImageCell", for: indexPath)
                    
                } else {
                    cell = tableView.dequeueReusableCell(withIdentifier: "WLTodayNewsCell", for: indexPath)
                }
                cell.tag = indexPath.row
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "WLFullScreenImageCell", for: indexPath)
            }
            
            (cell as! CellConfigurable).configure(dataObject: dataObject)
            return cell
        }
        let frameOfGradient = CGRect(x:0, y:0, width: UIApplication.shared.statusBarFrame.width, height: (CGFloat(tableView.frame.height / 1.95).rounded(.up)) - 44 - 80)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "WLYesterdayNewsCell", for: indexPath) as! WLYesterdayNewsCell
        cell.gradientView.backgroundColor = GradientColor(.topToBottom, frame:frameOfGradient, colors:  [UIColor.init(hexString:"#2e343e")!.withAlphaComponent(0.0) , UIColor.init(hexString:"2e343e")!.withAlphaComponent(2.0)])
        cell.btnContainerView.backgroundColor = UIColor.init(hexString:"2e343e")
        let dataObject = dataSource.fetchedResultsController.object(at: indexPath) as! NSManagedObject
        cell.tag = indexPath.row
        (cell as! CellConfigurable).configure(dataObject: dataObject)
        return cell
        
    }
    

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? CellConfigurable
        let dataObject = dataSource.fetchedResultsController.object(at: indexPath) as! WLNews
        if dataObject is WLArticle {
            performSegue(withIdentifier: "NewsDetailSegue", sender: cell)
        } else if dataObject is WLLink {
            performSegue(withIdentifier: "LinkDetailSegue", sender: cell)

        }
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if dataSource.fetchedResultsController.sections![section].name.isEmpty {
            return CGFloat.leastNormalMagnitude
        }
        return tableView.frame.height
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if dataSource.fetchedResultsController.sections![section].name.isEmpty {
            return nil
        }
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "WLTableHeaderView") as! WLTableHeaderView
        view.lblSectionName.text = dataSource.fetchedResultsController.sections![section].name
        view.contentView.backgroundColor = self.view.backgroundColor
        view.lblSectionName.textColor = self.navigationController?.navigationBar.tintColor
        return view
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if dataSource.fetchedResultsController.sections![indexPath.section].name.isEmpty {
            return tableView.frame.height
        }
        return CGFloat(tableView.frame.height / 1.95).rounded(.up)
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: IndexPath) -> Bool {
        return false
    }
}

extension WLNewsViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        // pop safari view controller and display navigation bar again
        print(navigationController?.viewControllers)
        navigationController?.popViewController(animated: true)
        navigationController?.isNavigationBarHidden = false
    }
}
