//
//  WLArticle+CoreDataProperties.swift
//  WhiteLabelApp
//
//  Created by Taras Serbin on 7/20/17.
//  Copyright © 2017 Taras Serbin. All rights reserved.
//

import Foundation
import CoreData


extension WLArticle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WLArticle> {
        return NSFetchRequest<WLArticle>(entityName: "WLArticle")
    }

    @NSManaged public var body: String?
    @NSManaged public var shortText: String?
    @NSManaged public var articleLayout: WLArticleLayout?
  

}
