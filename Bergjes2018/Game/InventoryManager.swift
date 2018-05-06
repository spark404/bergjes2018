//
//  InventoryManager.swift
//  Bergjes2018
//
//  Created by Hugo Trippaers on 06/05/2018.
//  Copyright © 2018 Hugo Trippaers. All rights reserved.
//

import Foundation
import os.log

struct PropertyKey {
    static let name = "name"
    static let amount = "amount"
}

class Item: NSObject, NSCoding {
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("inventory")

    var name: String
    var amount: Int
    
    init(name: String, amount: Int) {
        self.name = name;
        self.amount = amount;
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(amount, forKey: PropertyKey.amount)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for an inventory object.", log: OSLog.default, type: .debug)
            return nil
        }
        let amount = aDecoder.decodeInteger(forKey: PropertyKey.amount)
        
        self.init(name: name, amount: amount)
    }
    
}

class InventoryManager {
    var inventory: [Item]
    
    init() {
        inventory = InventoryManager.loadInventory() ?? []
        NSLog("Loaded \(inventory.count) items from static inventory")
    }
    
    func loadInventory(cleanInventory: [GameItem]) -> [GameItem] {
        var completedInventory: [GameItem] = []
        for gameItem in cleanInventory {
            if let index = inventory.index(where: { $0.name == gameItem.name}) {
                gameItem.amount = inventory[index].amount
                NSLog("Updating amount of \(gameItem.name) to \(gameItem.amount) in game inventory")
            }
            completedInventory.append(gameItem)
        }
        
        return completedInventory
    }
    
    func updateInventory(gameItems: [GameItem]) {
        for gameItem in gameItems {
            if let index = inventory.index(where: { $0.name == gameItem.name}) {
                inventory[index].amount = gameItem.amount;
                NSLog("Updating amount of \(gameItem.name) to \(gameItem.amount) in static inventory")
            } else {
                let item = Item(name: gameItem.name, amount: gameItem.amount)
                inventory.append(item)
                NSLog("Adding \(gameItem.name) with amount  \(gameItem.amount) to static inventory")
            }
        }
        
        self.storeInventory()
    }
    
    private func storeInventory() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(inventory, toFile: Item.ArchiveURL.path)
        
        if isSuccessfulSave {
            os_log("Inventory successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save inventory...", log: OSLog.default, type: .error)
        }
    }
    
    static private func loadInventory() -> [Item]? {
        return (NSKeyedUnarchiver.unarchiveObject(withFile: Item.ArchiveURL.path) as? [Item])
    }
    
}
