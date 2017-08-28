//
//  WLAsset+CoreDataProperties.swift
//  WhiteLabelApp
//
//  Created by Taras Serbin on 4/18/17.
//  Copyright © 2017 Taras Serbin. All rights reserved.
//

import Foundation
import CoreData


extension WLAsset {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WLAsset> {
        return NSFetchRequest<WLAsset>(entityName: "WLAsset");
    }

    @NSManaged public var identifier: String?
    @NSManaged public var internetMediaType: String?
    @NSManaged public var url: String?
    @NSManaged public var news: WLNews?
    @NSManaged public var brandInverse: WLBrand?

}
