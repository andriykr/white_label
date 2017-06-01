//
//  WLArticle+CoreDataProperties.swift
//  WhiteLabelApp
//
//  Created by Taras Serbin on 5/5/17.
//  Copyright © 2017 Taras Serbin. All rights reserved.
//

import Foundation
import CoreData


extension WLArticle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WLArticle> {
        return NSFetchRequest<WLArticle>(entityName: "WLArticle");
    }

    @NSManaged public var backgroundColor: String?
    @NSManaged public var body: String?
    @NSManaged public var date: Date?
    @NSManaged public var headline: String?
    @NSManaged public var identifier: String?
    @NSManaged public var isBookmark: Bool
    @NSManaged public var isFullScreen: Bool

    @NSManaged public var shortText: String?
    @NSManaged public var textColor: String?
    @NSManaged public var brand: NSOrderedSet?
    @NSManaged public var headerimage: WLAsset?
    @NSManaged public var articleLayout: WLArticleLayout?
    var sectionName: String? {
        
        if !Calendar.current.isDateInToday(date!) {
            return "Yesterday"
        }
        return ""
    }
}

// MARK: Generated accessors for brand
extension WLArticle {

    @objc(insertObject:inBrandAtIndex:)
    @NSManaged public func insertIntoBrand(_ value: WLBrand, at idx: Int)

    @objc(removeObjectFromBrandAtIndex:)
    @NSManaged public func removeFromBrand(at idx: Int)

    @objc(insertBrand:atIndexes:)
    @NSManaged public func insertIntoBrand(_ values: [WLBrand], at indexes: NSIndexSet)

    @objc(removeBrandAtIndexes:)
    @NSManaged public func removeFromBrand(at indexes: NSIndexSet)

    @objc(replaceObjectInBrandAtIndex:withObject:)
    @NSManaged public func replaceBrand(at idx: Int, with value: WLBrand)

    @objc(replaceBrandAtIndexes:withBrand:)
    @NSManaged public func replaceBrand(at indexes: NSIndexSet, with values: [WLBrand])

    @objc(addBrandObject:)
    @NSManaged public func addToBrand(_ value: WLBrand)

    @objc(removeBrandObject:)
    @NSManaged public func removeFromBrand(_ value: WLBrand)

    @objc(addBrand:)
    @NSManaged public func addToBrand(_ values: NSOrderedSet)

    @objc(removeBrand:)
    @NSManaged public func removeFromBrand(_ values: NSOrderedSet)

}
