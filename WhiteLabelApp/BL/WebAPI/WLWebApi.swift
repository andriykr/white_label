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
                print(entry)
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
    
    func getNews(_ matching:[String:Any], brand:WLBrand, completion:@escaping (_ links:[WLNews]?, _ error:Error?) -> Void) {
        client.fetchEntries(matching: matching) { linksResult in
            switch linksResult {
            case .success(let arrayOfLinks):
                var matching = matching
                matching["content_type"] = ArticleContetntTypeID
                self.client.fetchEntries(matching: matching, completion: { (articlesResult) in
                    switch articlesResult {
                    case .success(let arrayOfArticles):
                        var arrayOfIds = [String]()
                        let articles = arrayOfArticles.items
                        let links = arrayOfLinks.items
                        var result = [WLNews]()
                        DispatchQueue.main.sync {
                            for articleDic in articles {
                                arrayOfIds.append(articleDic.identifier)
                                if let article = WLArticle.from(entry: articleDic) {
                                    let tmpSet = article.brand as? NSMutableOrderedSet
                                    tmpSet?.add(brand)
                                    article.brand = tmpSet
                                    result.append(article)
                                }
                            }
                            for linkDic in links {
                                arrayOfIds.append(linkDic.identifier)
                                if let link = WLLink.from(entry: linkDic) {
                                    let tmpSet = link.brand as? NSMutableOrderedSet
                                    tmpSet?.add(brand)
                                    link.brand = tmpSet
                                    result.append(link)
                                }
                            }
                            WLCoreDataManager.shared.saveContext()
                            WLCoreDataManager.shared.deleteNews(arrayOfIds: arrayOfIds)
                            
                            completion(result,nil)
                        }
                    case .error(let error):
                        completion(nil, error)
                    }
                })
            case .error(let error):
                completion(nil, error)
            }
        }
    }
    
    func getLastDate(_ matching:[String:Any], completion:@escaping (_ date:Date?, _ error:Error?) -> Void) {
        client.fetchEntries(matching: matching) { resultArticles in
            switch resultArticles {
            case .success(let arrayArticles):
                let dateFormater = DateFormatter.init()
                dateFormater.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSz"
                var lastArticleDate = PreferenceManager.shared.lastDate
                if let articlesEntry = arrayArticles.items.last {
                    if let updateArticlesStr = articlesEntry.sys["updatedAt"] as? String {
                        lastArticleDate = dateFormater.date(from: updateArticlesStr)
                    }
                }
                var matching = matching
                matching["content_type"] = LinkContentTypeID
                self.client.fetchEntries(matching: matching, completion: { (resultLinks) in
                    switch resultLinks {
                    case .success(let linksArray):
                        if let linksEntry = linksArray.items.last {
                            if let updateLinksStr = linksEntry.sys["updatedAt"] as? String {
                                
                                if let linksDate = dateFormater.date(from: updateLinksStr) {
                                    completion(lastArticleDate! > linksDate ? lastArticleDate : linksDate, nil)
                                } else {
                                    completion(lastArticleDate! > PreferenceManager.shared.lastDate! ? lastArticleDate : PreferenceManager.shared.lastDate, nil)
                                }
                            } else {
                                completion(lastArticleDate! > PreferenceManager.shared.lastDate! ? lastArticleDate : PreferenceManager.shared.lastDate, nil)
                            }
                        } else {
                            completion(lastArticleDate! > PreferenceManager.shared.lastDate! ? lastArticleDate : PreferenceManager.shared.lastDate, nil)
                        }
                    case .error(let error):
                        completion(nil, error)
                    }
                })
            case .error(let error):
                completion(nil, error)
            }
        }
        
    }
}
