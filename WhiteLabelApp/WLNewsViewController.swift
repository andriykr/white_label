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

class WLNewsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityView: UIView!
    lazy var dataManager: WLCoreDataManager = {
        return WLCoreDataManager.shared
    }()
    
    lazy var dataSource:WLDataSource = {
        let resultsController = try! self.dataManager.fetchedResultsController(forContentType: WLArticle.self, predicate: self.predicate, sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)], sectionName:self.sectionName)
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
        if let vc = segue.destination as? WLNewsDetailViewController, let cell = sender as? CellConfigurable {
            vc.dataObjectIdetifier = cell.dataObjectIdentifier
            vc.image = cell.imageArticle
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
            let cell:UITableViewCell!
            let dataObject = dataSource.fetchedResultsController.object(at: indexPath) as! WLArticle
            if dataObject.articleLayout?.layoutType?.name == fullScreenLayoutName {
                cell = tableView.dequeueReusableCell(withIdentifier: "WLFullScreenImageCell", for: indexPath)
                
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "WLTodayNewsCell", for: indexPath)
            }
            cell.tag = indexPath.row
            (cell as! CellConfigurable).configure(dataObject: dataObject)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "WLYesterdayNewsCell", for: indexPath)
        let dataObject = dataSource.fetchedResultsController.object(at: indexPath) as! NSManagedObject
        cell.tag = indexPath.row

        (cell as! CellConfigurable).configure(dataObject: dataObject)
        return cell
        
    }
    

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       let cell = tableView.cellForRow(at: indexPath) as? CellConfigurable
        performSegue(withIdentifier: "NewsDetailSegue", sender: cell)
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
        return CGFloat(tableView.frame.height / 2.5).rounded(.up)
    }
}

