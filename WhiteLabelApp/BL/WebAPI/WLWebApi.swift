//
//  File.swift
//  WhiteLabelApp
//
//  Created by Taras Serbin on 4/18/17.
//  Copyright © 2017 Taras Serbin. All rights reserved.
//

import Foundation
import Contentful
import CoreData

let SPACE_ID = "dkpktv0iuhiz"
let ACCESS_TOKEN = "4e6df0fa4e6d73e9b3fce419ae71ed1cb516409a29c82739456d53dc6473d3b7"

class WLWebApi {
    static let shared = WLWebApi()
    let client: Client = Client(spaceIdentifier: SPACE_ID, accessToken: ACCESS_TOKEN)
    
    func getBrand(identifier:String, completion:@escaping (_ brand:WLBrand?, _ error:Error?) -> Void) {
        client.fetchEntry(identifier: identifier) { (result) in
            switch result {
            case .success(let entry):
                var brand:WLBrand? = nil
                do {
                    brand = WLBrand.init(entity: NSEntityDescription.entity(forEntityName: "WLBrand", in: WLCoreDataManager.shared.managedObjectContext)!,
                                         insertInto: WLCoreDataManager.shared.managedObjectContext)
                    brand?.identifier = identifier
                    if let themeDic = entry.fields["theme"] as? [String:String] {
                        let theme = WLBrandTheme.from(dictionary:themeDic)
                        brand?.theme = theme
                    }
                    brand?.name = entry.fields["name"] as? String
                    if let imgEntry = entry.fields["logo"] as? [String:[String:Any]] {
                        self.client.fetchAsset(identifier: imgEntry["sys"]!["id"] as! String, completion: { (result) in
                            switch result{
                            case .success(let assetBrand):
                                if let asset = WLAsset.from(entry: assetBrand) {
                                    brand?.logo = asset
                                    asset.brandInverse = brand
                                    completion(brand, nil)
                                }
                            case .error(let error):
                                completion(nil, error)
                            }
                        })
                    }
                    
                }
            case .error(let error):
                completion(nil, error)
            }
        }
    }
    
    func getArticles(_ matching:[String:Any], brand:WLBrand, completion:@escaping (_ articles:[WLArticle]?, _ error:Error?) -> Void) {
        client.fetchEntries(matching: matching) { result in
            switch result {
            case .success(let array):
                var arrayOfIds = [String]()
                let articles = array.items
                var result = [WLArticle]()
                DispatchQueue.main.async {
                    for articleDic in articles {
                        arrayOfIds.append(articleDic.identifier)
                        if let article = WLArticle.from(entry: articleDic) {
                            let tmpSet = article.brand as? NSMutableOrderedSet
                            tmpSet?.add(brand)
                            article.brand = tmpSet
                            result.append(article)
                        }
                    }
                    WLCoreDataManager.shared.saveContext()
                    WLCoreDataManager.shared.deleteArticles(arrayOfIds: arrayOfIds)
                }
                completion(result, nil)
            case .error(let error):
                completion(nil, error)
            }
        }
    }
    
    
    
    func getLastDate(_ matching:[String:Any], completion:@escaping (_ date:Date?, _ error:Error?) -> Void) {
        client.fetchEntries(matching: matching) { result in
            switch result {
            case .success(let array):
                if let entry = array.items.last {
                    if let updateStr =  entry.sys["updatedAt"] as? String {
                        let dateFormater = DateFormatter.init()
                        dateFormater.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSz"
                        completion(dateFormater.date(from: updateStr), nil)
                        
                    }
                } else {
                    if let date = WLCoreDataManager.shared.getLastArticleDate(from: PreferenceManager.shared.lastDate!) {
                        completion(date, nil)
                    }
                    completion(PreferenceManager.shared.lastDate, nil)
                }
            case .error(let error):
                completion(nil, error)
            }
        }
        
    }
}
