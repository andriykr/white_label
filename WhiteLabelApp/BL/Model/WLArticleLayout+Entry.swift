//
//  WLArticleLayout+Entry.swift
//  WhiteLabelApp
//
//  Created by Taras Serbin on 5/5/17.
//  Copyright © 2017 Taras Serbin. All rights reserved.
//

import UIKit
import Contentful
import CoreData

extension WLArticleLayout {
    static func from(entry:Entry) -> WLArticleLayout? {
        var articleLayout:WLArticleLayout! = nil
        if let layout = WLCoreDataManager.shared.getArticleLayout(identifier:(entry.identifier)) {
            articleLayout = layout
        } else {
            articleLayout =  WLArticleLayout.init(entity: NSEntityDescription.entity(forEntityName: "WLArticleLayout", in: WLCoreDataManager.shared.managedObjectContext)!,
                                      insertInto: WLCoreDataManager.shared.managedObjectContext)
        }
        
        articleLayout.identifier = entry.identifier
        articleLayout.name = entry.fields["name"] as? String
        articleLayout.backgroundColor = entry.fields["backgroundColor"] as? String
        articleLayout.textColor = entry.fields["textColor"] as? String
        if let layoutEntry = entry.fields["type"] as? Entry {
            articleLayout.layoutType = WLLayoutType.from(entry:layoutEntry)
        }
        return articleLayout
    }
}
