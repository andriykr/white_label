//
//  WLCoreDataManager.swift
//  WhiteLabelApp
//
//  Created by Taras Serbin on 4/18/17.
//  Copyright © 2017 Taras Serbin. All rights reserved.
//


import Foundation
import CoreData
import Contentful
import ContentfulPersistence

extension NSNotification.Name {
    static let linkReceived = NSNotification.Name("Link data received")
}
let BrandContentTypeId = "brand"
let ArticleContetntTypeID = "article"
let LinkContentTypeID = "link"
class WLCoreDataManager:NSObject {
    // MARK: - Core Data stack
    static let shared = WLCoreDataManager()
   
   private override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(updateLink(notification:)), name: .linkReceived, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .linkReceived, object: nil)
    }
    private lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "WLDataModel", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("WLDataModel.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            // Configure automatic migration.
            let options = [ NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption : true ]
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        var managedObjectContext: NSManagedObjectContext?
        if #available(iOS 10.0, *){
            
            managedObjectContext = self.persistentContainer.viewContext
        }
        else {
            let coordinator = self.persistentStoreCoordinator
            managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            managedObjectContext?.persistentStoreCoordinator = coordinator
        }
        return managedObjectContext!
    }()
    
    lazy var store: CoreDataStore = {
        return CoreDataStore(context: self.managedObjectContext)
    }()
    
    func updateLink(notification:NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        guard let identifier = userInfo["identifier"] as? String else {return}
        guard let link = getNews(identifier: identifier) as? WLLink else {return}
        if let title = userInfo["title"] as? String {
            link.headline = title
        }
        
        if let description = userInfo["description"] as? String{
            link.shortText = description
        }
        
        if let urlImage = userInfo["previewImage"] as? String {
            link.image = urlImage
        }
        saveContext()
    }
    
    func fetchedResultsController(forContentType type: Any.Type, predicate: NSPredicate, sortDescriptors: [NSSortDescriptor], sectionName:String?) throws -> NSFetchedResultsController<NSFetchRequestResult> {
        let fetchRequest = try store.fetchRequest(for: type, predicate: predicate)
        fetchRequest.sortDescriptors = sortDescriptors
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath:sectionName, cacheName: nil)
    }
    
    func performSynchronization(completion: @escaping (Bool, _ error:Error?) -> ()) {
        let queryParameters = [
            "content_type": LinkContentTypeID,
            "fields.brand.sys.id": BRAND_ID,
            "include": 2] as [String : Any]
        
        WLWebApi.shared.getNews(queryParameters, brand:getBrand(identifier: BRAND_ID)!) { (articles, error) in
            if error == nil {
                completion(true, nil)
                
            } else {
                completion(false, error)
            }
        }
    }
    
    func getBrand(identifier:String) -> WLBrand? {
        let fetchRequest:NSFetchRequest<WLBrand> = WLBrand.fetchRequest()
        let predicate = NSPredicate.init(format: "identifier = %@", identifier)
        fetchRequest.predicate = predicate
        do {
            let brands = try WLCoreDataManager.shared.managedObjectContext.fetch(fetchRequest)
            
            return brands.first
            
        } catch _ as NSError {
            return nil
        }
    }
    
    func getNews(identifier:String) -> WLNews? {
        let fetchRequest:NSFetchRequest<WLNews> = WLNews.fetchRequest()
        let predicate = NSPredicate.init(format: "identifier = %@", identifier)
        fetchRequest.predicate = predicate
        do {
            let news = try WLCoreDataManager.shared.managedObjectContext.fetch(fetchRequest)
            return news.first
        } catch _ as NSError {
            return nil
        }
    }
    
    func getArticleLayout(identifier:String) -> WLArticleLayout? {
        let fetchRequest:NSFetchRequest<WLArticleLayout> = WLArticleLayout.fetchRequest()
        let predicate = NSPredicate.init(format: "identifier = %@", identifier)
        fetchRequest.predicate = predicate
        do {
            let layouts = try WLCoreDataManager.shared.managedObjectContext.fetch(fetchRequest)
            return layouts.first
        } catch _ as NSError {
            return nil
        }
    }
    func deleteNews(arrayOfIds:[String]) {
        let fetchRequest:NSFetchRequest<WLNews> = WLNews.fetchRequest()
        let predicate = NSPredicate.init(format: "NOT (identifier IN %@)", arrayOfIds)
        fetchRequest.predicate = predicate
        do {
            let articles = try WLCoreDataManager.shared.managedObjectContext.fetch(fetchRequest)
            for article in articles {
                managedObjectContext.delete(article)
            }
        } catch {
            
        }
    }
    
    func getLastNewsDate(from:Date) -> Date? {
        let fetchRequest:NSFetchRequest<WLNews> = WLNews.fetchRequest()
        let predicate = NSPredicate.init(format: "date < %@", from as CVarArg)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            let news = try WLCoreDataManager.shared.managedObjectContext.fetch(fetchRequest)
            return news.first?.date
        } catch {
            return nil
        }
    }
    func getLayoutType(identifier:String) -> WLLayoutType? {
        let fetchRequest:NSFetchRequest<WLLayoutType> = WLLayoutType.fetchRequest()
        let predicate = NSPredicate.init(format: "identifier = %@", identifier)
        fetchRequest.predicate = predicate
        do {
            let types = try WLCoreDataManager.shared.managedObjectContext.fetch(fetchRequest)
            return types.first
        } catch _ as NSError {
            return nil
        }
    }
    
  

    
    // iOS-10
    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "WLDataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                abort()
            }
        }
    }
}
