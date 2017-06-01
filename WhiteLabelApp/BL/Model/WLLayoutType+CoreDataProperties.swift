//
//  WLLayoutType+CoreDataProperties.swift
//  WhiteLabelApp
//
//  Created by Taras Serbin on 5/5/17.
//  Copyright © 2017 Taras Serbin. All rights reserved.
//

import Foundation
import CoreData


extension WLLayoutType {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WLLayoutType> {
        return NSFetchRequest<WLLayoutType>(entityName: "WLLayoutType");
    }

    @NSManaged public var identifier: String?
    @NSManaged public var name: String?

}
