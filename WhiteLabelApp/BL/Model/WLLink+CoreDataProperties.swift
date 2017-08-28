//
//  WLLink+CoreDataProperties.swift
//  WhiteLabelApp
//
//  Created by Taras Serbin on 7/26/17.
//  Copyright © 2017 Taras Serbin. All rights reserved.
//

import Foundation
import CoreData


extension WLLink {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WLLink> {
        return NSFetchRequest<WLLink>(entityName: "WLLink")
    }

    @NSManaged public var link: String?
    @NSManaged public var image: String?
    @NSManaged public var shortText: String?

}
