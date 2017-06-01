//
//  WLBookmarksViewController.swift
//  WhiteLabelApp
//
//  Created by Taras Serbin on 5/4/17.
//  Copyright © 2017 Taras Serbin. All rights reserved.
//

import UIKit
import CoreData

class WLBookmarksViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
  
    lazy var dataManager: WLCoreDataManager = {
        return WLCoreDataManager.shared
    }()
    
    lazy var dataSource:WLDataSource = {
        let resultsController = try! self.dataManager.fetchedResultsController(forContentType: WLArticle.self, predicate: self.predicate, sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)], sectionName:nil)
        return WLDataSource(fetchedResultsController: resultsController, tableView: self.tableView)
    }()
    
    //    var predicate: NSPredicate = NSPredicate.init(format: "ANY brand.identifier == %@", BRAND_ID)
    var predicate: NSPredicate = NSPredicate.init(format: "isBookmark == %@", "1")
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    func refresh() {
        let refresh = {
            try self.dataSource.performFetch()
            NotificationCenter.default.addObserver(self, selector: #selector(WLNewsViewController.refresh), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        }
        do {
            try refresh()
        } catch {}
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if let theme =  WLCoreDataManager.shared.getBarnd(identifier: BRAND_ID)?.theme {
            self.navigationController?.navigationBar.titleTextAttributes = [
                NSForegroundColorAttributeName : UIColor.init(hexString: theme.titleColor!)!
            ]
            view.backgroundColor =  UIColor.init(hexString: theme.bodyBackgroundColor!)!
        }

        tableView.register(UINib.init(nibName: "WLYesterdayNewsCell", bundle: nil), forCellReuseIdentifier:  "WLYesterdayNewsCell")
         tableView.register(UINib.init(nibName: "WLEmtyCell", bundle: nil), forCellReuseIdentifier:  "WLEmtyCell")
        tableView.dataSource = self
        tableView.delegate = self
        
        
        print(self.view.frame.height)
        tableView.sectionHeaderHeight = 0
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        refresh()
        
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
    
    @IBAction func btnBackTapped(_ sender: UIBarButtonItem) {
        let _ = navigationController?.popViewController(animated: true)
    }
}

extension WLBookmarksViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataSource.fetchedResultsController.fetchedObjects?.count == 0 {
            return 1
        }
        return dataSource.fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if dataSource.fetchedResultsController.fetchedObjects?.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WLEmtyCell", for: indexPath)
            let v = UIView.init()
            v.backgroundColor = UIColor.clear
            cell.selectedBackgroundView? = v
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "WLYesterdayNewsCell", for: indexPath)
        let dataObject = dataSource.fetchedResultsController.object(at: indexPath) as! NSManagedObject
        cell.tag = indexPath.row
        (cell as! CellConfigurable).configure(dataObject: dataObject)
        return cell
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let _ = tableView.cellForRow(at: indexPath) as? WLYesterdayNewsCell {
            return indexPath
        }
        return nil
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? CellConfigurable
        performSegue(withIdentifier: "BookmarkDetailSegue", sender: cell)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if dataSource.fetchedResultsController.sections![section].name.isEmpty {
            return CGFloat.leastNormalMagnitude
        }
        return tableView.frame.height
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(tableView.frame.height / 2.5).rounded(.up)
    }
}

