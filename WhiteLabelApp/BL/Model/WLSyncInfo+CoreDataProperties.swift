//
//  WLSyncInfo+CoreDataProperties.swift
//  WhiteLabelApp
//
//  Created by Taras Serbin on 4/18/17.
//  Copyright © 2017 Taras Serbin. All rights reserved.
//

import Foundation
import CoreData


extension WLSyncInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WLSyncInfo> {
        return NSFetchRequest<WLSyncInfo>(entityName: "WLSyncInfo");
    }

    @NSManaged public var lastSyncTimestamp: NSDate?
    @NSManaged public var syncToken: String?

}
