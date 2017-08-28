//
//  WLBrand+CoreDataProperties.swift
//  WhiteLabelApp
//
//  Created by Taras Serbin on 7/20/17.
//  Copyright © 2017 Taras Serbin. All rights reserved.
//

import Foundation
import CoreData


extension WLBrand {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WLBrand> {
        return NSFetchRequest<WLBrand>(entityName: "WLBrand")
    }

    @NSManaged public var identifier: String?
    @NSManaged public var name: String?
    @NSManaged var theme: WLBrandTheme?
    @NSManaged public var articles: NSOrderedSet?
    @NSManaged public var logo: WLAsset?

}

// MARK: Generated accessors for articles
extension WLBrand {

    @objc(insertObject:inArticlesAtIndex:)
    @NSManaged public func insertIntoArticles(_ value: WLNews, at idx: Int)

    @objc(removeObjectFromArticlesAtIndex:)
    @NSManaged public func removeFromArticles(at idx: Int)

    @objc(insertArticles:atIndexes:)
    @NSManaged public func insertIntoArticles(_ values: [WLNews], at indexes: NSIndexSet)

    @objc(removeArticlesAtIndexes:)
    @NSManaged public func removeFromArticles(at indexes: NSIndexSet)

    @objc(replaceObjectInArticlesAtIndex:withObject:)
    @NSManaged public func replaceArticles(at idx: Int, with value: WLNews)

    @objc(replaceArticlesAtIndexes:withArticles:)
    @NSManaged public func replaceArticles(at indexes: NSIndexSet, with values: [WLNews])

    @objc(addArticlesObject:)
    @NSManaged public func addToArticles(_ value: WLNews)

    @objc(removeArticlesObject:)
    @NSManaged public func removeFromArticles(_ value: WLNews)

    @objc(addArticles:)
    @NSManaged public func addToArticles(_ values: NSOrderedSet)

    @objc(removeArticles:)
    @NSManaged public func removeFromArticles(_ values: NSOrderedSet)

}
