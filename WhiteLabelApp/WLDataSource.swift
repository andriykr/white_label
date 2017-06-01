//
//  WLDataSource.swift
//  WhiteLabelApp
//
//  Created by Taras Serbin on 4/18/17.
//  Copyright © 2017 Taras Serbin. All rights reserved.
//

import Foundation
import CoreData
import UIKit

protocol CellConfigurable : CellIdentifiable {
    var imageArticle:UIImage?  { get }
    var dataObjectIdentifier:String  { get }
    func configure(dataObject: NSManagedObject)
    
}

protocol CellIdentifiable {
    static var cellIdentifier: String { get }

}

extension UITableViewCell : CellIdentifiable {
    @nonobjc static let cellIdentifier = String(describing: type(of: self))
}

// MARK: -

class WLDataSource: NSObject, NSFetchedResultsControllerDelegate {

    let fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>
    let tableView: UITableView?
    
    var objectChanges = [[NSFetchedResultsChangeType:[NSIndexPath]]]()
    var sectionChanges = [[NSFetchedResultsChangeType:Int]]()
    
    
    init(fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>, tableView: UITableView) {
        self.fetchedResultsController = fetchedResultsController
        self.tableView = tableView
        
        super.init()
        
        self.fetchedResultsController.delegate = self
    }
    
    func performFetch() throws {
        try fetchedResultsController.performFetch()
        tableView?.reloadData()
    }
    
    //MARK - FetchResultControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if fetchedResultsController.fetchedObjects?.count == 0 {
            tableView?.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .fade)
        }
        tableView?.endUpdates()
        tableView?.reloadData()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
              switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView?.insertRows(at: [indexPath], with: .fade)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                tableView?.deleteRows(at: [indexPath], with: .fade)
            }
            break;
        case .update:
            if let indexPath = indexPath {
                
                if let dataObject = fetchedResultsController.object(at: indexPath) as? NSManagedObject {
                    
                    if let cell = tableView?.cellForRow(at: indexPath) {
                        (cell as! CellConfigurable).configure(dataObject: dataObject)
                    }
                }
            }
            break;
        case .move:
            if let indexPath = indexPath {
                tableView?.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView?.insertRows(at: [newIndexPath], with: .fade)
            }
            break;
        }
    }
}



