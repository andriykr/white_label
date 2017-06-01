//
//  WLArticleLayout+CoreDataProperties.swift
//  WhiteLabelApp
//
//  Created by Taras Serbin on 5/5/17.
//  Copyright © 2017 Taras Serbin. All rights reserved.
//

import Foundation
import CoreData


extension WLArticleLayout {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WLArticleLayout> {
        return NSFetchRequest<WLArticleLayout>(entityName: "WLArticleLayout");
    }

    @NSManaged public var identifier: String?
    @NSManaged public var name: String?
    @NSManaged public var backgroundColor: String?
    @NSManaged public var textColor: String?
    @NSManaged public var layoutType: WLLayoutType?

}
