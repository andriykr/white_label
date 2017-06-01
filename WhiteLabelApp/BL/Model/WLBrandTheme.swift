//
//  WLBrandTheme.swift
//  WhiteLabelApp
//
//  Created by Taras Serbin on 4/18/17.
//  Copyright © 2017 Taras Serbin. All rights reserved.
//

import Foundation

class WLBrandTheme:NSObject, NSCoding  {
    let titleColor:String?
    let bodyColor:String?
    let bodyBackgroundColor:String?
    let cellBackgroundColor:String?
    let accentColor:String?
    
    init(titleColor:String, bodyColor:String, bodyBackgroundColor:String, cellBackgroundColor:String, accentColor:String) {
        self.titleColor = titleColor
        self.bodyColor = bodyColor
        self.cellBackgroundColor = cellBackgroundColor
        self.bodyBackgroundColor = bodyBackgroundColor
        self.accentColor = accentColor
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let titleColor = aDecoder.decodeObject(forKey: "titleColor") as? String,
                    let bodyColor = aDecoder.decodeObject(forKey: "bodyColor") as? String,
                    let cellBackgroundColor = aDecoder.decodeObject(forKey: "cellBackgroundColor") as? String,
                    let bodyBackgroundColor = aDecoder.decodeObject(forKey: "bodyBackgroundColor") as? String,
                    let accentColor = aDecoder.decodeObject(forKey: "accentColor") as? String else {
                return nil
        }
        
        self.init(titleColor:titleColor, bodyColor:bodyColor, bodyBackgroundColor: bodyBackgroundColor, cellBackgroundColor:cellBackgroundColor, accentColor:accentColor)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(titleColor, forKey: "titleColor")
        aCoder.encode(bodyColor, forKey: "bodyColor")
        aCoder.encode(bodyBackgroundColor, forKey: "bodyBackgroundColor")
        aCoder.encode(cellBackgroundColor, forKey: "cellBackgroundColor")
        aCoder.encode(accentColor, forKey: "accentColor")
    }
    
   static func from(dictionary:[String:String]) -> WLBrandTheme? {
        guard let titleColor = dictionary["titleColor"],
            let bodyColor = dictionary["bodyColor"],
            let cellBackgroundColor = dictionary["cellBackgroundColor"],
            let bodyBackgroundColor = dictionary["bodyBackgroundColor"],
            let accentColor = dictionary["accentColor"] else {
                return nil
        }
        
        return WLBrandTheme.init(titleColor:titleColor, bodyColor:bodyColor, bodyBackgroundColor: bodyBackgroundColor, cellBackgroundColor:cellBackgroundColor, accentColor:accentColor)
    }
}
