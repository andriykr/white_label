//
//  WLLink+Entry.swift
//  WhiteLabelApp
//
//  Created by Taras Serbin on 7/20/17.
//  Copyright © 2017 Taras Serbin. All rights reserved.
//



import UIKit
import Contentful
import CoreData

extension WLLink {
    static func from(entry:Entry) -> WLLink? {
        var link:WLLink! = nil
        if let l = WLCoreDataManager.shared.getNews(identifier:(entry.identifier)) as? WLLink {
            link = l
        } else {
            link =  WLLink.init(entity: NSEntityDescription.entity(forEntityName: "WLLink", in: WLCoreDataManager.shared.managedObjectContext)!,
                                insertInto: WLCoreDataManager.shared.managedObjectContext)
        }
        if let updateStr =  entry.sys["updatedAt"] as? String {
            let dateFormater = DateFormatter.init()
            dateFormater.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSz"
            link.date = dateFormater.date(from: updateStr)
        }
        
        if PreferenceManager.shared.lastDate != nil {
            if PreferenceManager.shared.lastDate! < link.date! {
                PreferenceManager.shared.lastDate = link.date
            }
        } else {
            PreferenceManager.shared.lastDate = link.date
        }
        link.identifier = entry.identifier
        if let imgAsset = entry.fields["headerImage"] as? Asset {
            if let img = WLAsset.from(entry: imgAsset) {
                link.headerimage = img
                img.news = link
            }
        } else {
            link.headerimage = nil
        }
        
        if link.link == nil || link.link != entry.fields["url"] as? String {
            link.link = entry.fields["url"] as? String
            if let url = URL(string: link.link!) {
                url.fetchPageInfo({ (title, description, previewImage) -> Void in
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    var result = [String:String]()
                    if let title = title {
                        result["title"] = title
                    }
                    
                    if let description = description {
                        result["description"] = description
                    }
                    
                    if let urlImage = previewImage {
                        result["previewImage"] = urlImage
                    }
                    result["identifier"] = link.identifier!
                    
                    NotificationCenter.default.post(name: .linkReceived, object: nil, userInfo: result)
                }, failure: { (errorMessage) -> Void in
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                })
            } else {
                print("Invalid URL!")
            }
        }
        
        
        
        return link
    }
}
