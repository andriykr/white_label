//
//  WLBrand+CoreDataProperties.swift
//  WhiteLabelApp
//
//  Created by Taras Serbin on 4/18/17.
//  Copyright © 2017 Taras Serbin. All rights reserved.
//

import Foundation
import CoreData


extension WLBrand {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WLBrand> {
        return NSFetchRequest<WLBrand>(entityName: "WLBrand");
    }

    @NSManaged public var identifier: String?
    @NSManaged public var name: String?
    @NSManaged var theme: WLBrandTheme?
    @NSManaged public var articles: NSOrderedSet?
    @NSManaged public var logo: WLAsset?

}

// MARK: Generated accessors for articles
extension WLBrand {

    @objc(addArticlesObject:)
    @NSManaged public func addToArticles(_ value: WLArticle)

    @objc(removeArticlesObject:)
    @NSManaged public func removeFromArticles(_ value: WLArticle)

    @objc(addArticles:)
    @NSManaged public func addToArticles(_ values: NSOrderedSet)

    @objc(removeArticles:)
    @NSManaged public func removeFromArticles(_ values: NSOrderedSet)

}
