//
//  PreferenceManager.swift
//  WhiteLabelApp
//
//  Created by Taras Serbin on 4/19/17.
//  Copyright © 2017 Taras Serbin. All rights reserved.
//

import UIKit

let lastDateUpdate = "Last Date Update"

class PreferenceManager {
    static let shared = PreferenceManager()
    let defaults = UserDefaults.standard
    var lastDate:Date? {
        get {
            return defaults.object(forKey: lastDateUpdate) as? Date
        }
        set {
            defaults.set(newValue, forKey: lastDateUpdate)
        }
    }
}
