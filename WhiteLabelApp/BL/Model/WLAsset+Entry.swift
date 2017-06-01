//
//  WLAsset+Entry.swift
//  WhiteLabelApp
//
//  Created by Taras Serbin on 4/19/17.
//  Copyright © 2017 Taras Serbin. All rights reserved.
//

import UIKit
import Contentful
import CoreData

extension WLAsset {
    static func from(entry:Asset) -> WLAsset? {
        let asset =  WLAsset.init(entity: NSEntityDescription.entity(forEntityName: "WLAsset", in: WLCoreDataManager.shared.managedObjectContext)!,
                                      insertInto: WLCoreDataManager.shared.managedObjectContext)
        asset.identifier = entry.identifier
        if let url =  (entry.fields["file"] as? [String:Any])?["url"] as? String {
            asset.url = "https:" + url
        }
        asset.internetMediaType = (entry.fields["file"] as? [String:Any])?["contentType"] as? String
       return asset
    }
}
