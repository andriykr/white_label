//
//  WLLayoutType+Entry.swift
//  WhiteLabelApp
//
//  Created by Taras Serbin on 5/5/17.
//  Copyright © 2017 Taras Serbin. All rights reserved.
//

import UIKit
import Contentful
import CoreData

extension WLLayoutType {
    static func from(entry:Entry) -> WLLayoutType? {
        var layoutType:WLLayoutType! = nil
        if let type = WLCoreDataManager.shared.getLayoutType(identifier:(entry.identifier)) {
            layoutType = type
        } else {
            layoutType =  WLLayoutType.init(entity: NSEntityDescription.entity(forEntityName: "WLLayoutType", in: WLCoreDataManager.shared.managedObjectContext)!,
                                                  insertInto: WLCoreDataManager.shared.managedObjectContext)
        }
        
        layoutType.identifier = entry.identifier
        layoutType.name = entry.fields["layoutName"] as? String
        return layoutType
    }
}
