//
//  File.swift
//  WhiteLabelApp
//
//  Created by Taras Serbin on 4/19/17.
//  Copyright © 2017 Taras Serbin. All rights reserved.
//

import UIKit
import Contentful
import CoreData

extension WLArticle {
    static func from(entry:Entry) -> WLArticle? {
        var article:WLArticle! = nil
        if let a = WLCoreDataManager.shared.getArticle(identifier:(entry.identifier)) {
            article = a
        } else {
            article =  WLArticle.init(entity: NSEntityDescription.entity(forEntityName: "WLArticle", in: WLCoreDataManager.shared.managedObjectContext)!,
                                    insertInto: WLCoreDataManager.shared.managedObjectContext)
        }
        article.headline = entry.fields["headline"] as? String
        article.identifier = entry.identifier
        article.body = entry.fields["body"] as? String
        if let updateStr =  entry.sys["updatedAt"] as? String {
            let dateFormater = DateFormatter.init()
            dateFormater.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSz"
            article.date = dateFormater.date(from: updateStr)
        }
        if let imgAsset = entry.fields["headerimage"] as? Asset {
        if let img = WLAsset.from(entry: imgAsset) {
            article.headerimage = img
            img.articleInverse = article
        }
        }
        article.shortText = entry.fields["shortText"] as? String
        if PreferenceManager.shared.lastDate != nil {
            if PreferenceManager.shared.lastDate! < article.date! {
                PreferenceManager.shared.lastDate = article.date
            }
        } else {
            PreferenceManager.shared.lastDate = article.date
        }
        if let articleLayoutEntry = entry.fields["layout"] as? Entry {
            article.articleLayout = WLArticleLayout.from(entry: articleLayoutEntry)
        }
        return article
    }
}
