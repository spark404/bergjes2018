//
//  InventoryManager.swift
//  Bergjes2018
//
//  Created by Hugo Trippaers on 06/05/2018.
//  Copyright © 2018 Hugo Trippaers. All rights reserved.
//

import Foundation



class InventoryManager {
    var inventory: [Item]
    
    init() {
        inventory = PersistenceManager.loadItems() ?? []
        NSLog("Loaded \(inventory.count) items from static inventory")
    }
    
    func loadInventory(cleanInventory: [GameItem]) -> [GameItem] {
        var completedInventory: [GameItem] = []
        for gameItem in cleanInventory {
            if let index = inventory.index(where: { $0.name == gameItem.name}),
                inventory[index].amount != gameItem.amount {
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
                if inventory[index].amount != gameItem.amount {
                    inventory[index].amount = gameItem.amount;
                    NSLog("Updating amount of \(gameItem.name) to \(gameItem.amount) in static inventory")
                }
            } else {
                let item = Item(name: gameItem.name, amount: gameItem.amount)
                inventory.append(item)
                NSLog("Adding \(gameItem.name) with amount  \(gameItem.amount) to static inventory")
            }
        }
        
        PersistenceManager.storeItems(items: inventory)
    }
    
}
