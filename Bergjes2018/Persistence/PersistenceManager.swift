//
//  PersistanceManager.swift
//  Bergjes2018
//
//  Created by Hugo Trippaers on 06/05/2018.
//  Copyright © 2018 Hugo Trippaers. All rights reserved.
//

import Foundation

class PersistenceManager {
    private init() {
        // Empty
    }
    
    static func storeItems(items: [Item]) {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(items, toFile: Item.ArchiveURL.path)
        
        if isSuccessfulSave {
            NSLog("Inventory successfully saved.")
        } else {
            NSLog("Failed to save inventory...")
        }
    }
    
    static func loadItems() -> [Item]? {
        return (NSKeyedUnarchiver.unarchiveObject(withFile: Item.ArchiveURL.path) as? [Item])
    }

    static func storeLocations(locations: [Location]) {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(locations, toFile: Location.ArchiveURL.path)
        
        if isSuccessfulSave {
            NSLog("Locations successfully saved.")
        } else {
            NSLog("Failed to save Locations...")
        }
    }
    
    static func loadLocations() -> [Location]? {
        return (NSKeyedUnarchiver.unarchiveObject(withFile: Location.ArchiveURL.path) as? [Location])
    }
    
    static func storeActions(actions: [Action]) {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(actions, toFile: Action.ArchiveURL.path)
        
        if isSuccessfulSave {
            NSLog("Actions successfully saved.")
        } else {
            NSLog("Failed to save Actions...")
        }
    }
    
    static func loadActions() -> [Action]? {
        return (NSKeyedUnarchiver.unarchiveObject(withFile: Action.ArchiveURL.path) as? [Action])
    }


}
