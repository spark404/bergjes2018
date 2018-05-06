//
//  GameManager.swift
//  Bergjes2018
//
//  Created by Hugo Trippaers on 29/04/2018.
//  Copyright © 2018 Hugo Trippaers. All rights reserved.
//

import Foundation
import UIKit

class GameManager {
    static let shared = GameManager()
    
    var currentLocationIdentifier: String?
    var delegate: GameManagerDelegate?
    
    var locations: [String: GameLocation] = [:]
    var inventory: [GameItem] = []
    
    var itemDescriptions: [String: String] = [:]
    var locationDescriptions: [String: String] = [:]
    
    var inventoryManager: InventoryManager
    
    private init() {
        inventoryManager = InventoryManager()
        readPropertyList()
        
        // Strocamp set
        locations = GameSetupStrocamp.loadLocations()
        inventory = inventoryManager.loadInventory(cleanInventory: GameSetupStrocamp.loadItems())
    }
    
    var distanceCalculator = DistanceCalculator()
    
    func retrieveVisibleLocations(curentLocationId: String?) -> [GameLocation] {
        if (curentLocationId == nil) {
            return []
        }
        
        var visibleLocations: [GameLocation] = [];
        // Self should be visible
        visibleLocations.append(retrieveLocationsDatabase()[curentLocationId!]!)
        
        switch curentLocationId {
        case "start":
            visibleLocations.append(retrieveLocationsDatabase()["boom"]!)
        case "boom":
            visibleLocations.append(retrieveLocationsDatabase()["koopman"]!)
            visibleLocations.append(retrieveLocationsDatabase()["houthakkershut"]!)
            visibleLocations.append(retrieveLocationsDatabase()["rivier"]!)
        case "koopman":
            visibleLocations.append(retrieveLocationsDatabase()["boom"]!)
            visibleLocations.append(retrieveLocationsDatabase()["houthakkershut"]!)
        case "houthakkershut":
            visibleLocations.append(retrieveLocationsDatabase()["boom"]!)
            visibleLocations.append(retrieveLocationsDatabase()["koopman"]!)
        case "rivier":
            visibleLocations.append(retrieveLocationsDatabase()["boom"]!)
            visibleLocations.append(retrieveLocationsDatabase()["kloofrand"]!)
            visibleLocations.append(retrieveLocationsDatabase()["moeras"]!)
        case "kloofrand":
            visibleLocations.append(retrieveLocationsDatabase()["rivier"]!)
            visibleLocations.append(retrieveLocationsDatabase()["kloofbodem"]!)
        case "kloofbodem":
            visibleLocations.append(retrieveLocationsDatabase()["kloofrand"]!)
        case "moeras":
            visibleLocations.append(retrieveLocationsDatabase()["rivier"]!)

        default:
            visibleLocations.append(retrieveLocationsDatabase()["start"]!)
        }
        
        return visibleLocations
    }
    
    func getColorForLocation(location: GameLocation) -> UIColor {
        if (location.name == currentLocationIdentifier) {
            return UIColor.blue;
        }
        
        return UIColor.red;
    }
    
    func retrieveBackpackContents() -> [GameItem] {
        return inventory
    }
    
    func attemptCombine(itemsToCombine: [GameItem]) -> GameItem? {
        if (itemsToCombine.count > 2) {
            return nil
        }
        
        NSLog("Attempt to use \(itemsToCombine[0].name) with \(itemsToCombine[1].name)")
        
        if itemsToCombine.contains(where: { $0.name == "Motor" }) &&
            itemsToCombine.contains(where: { $0.name == "Schroef" }) {
            
            removeItemFromInventory(itemName: itemsToCombine[0].name)
            removeItemFromInventory(itemName: itemsToCombine[1].name)
            addItemToInventory(itemName: "Schroefmotor")
            
            return inventory[inventory.index(where: {$0.name == "Schroefmotor"})!]
        }
        
        return nil
    }
    
    func attemptUse(itemToUse: GameItem) -> Bool {
        return false;
    }

    private func addItemToInventory(itemName: String) {
        let index = inventory.index(where: {$0.name == itemName})!
        inventory[index].amount += 1
        
        inventoryManager.updateInventory(gameItems: inventory)
    }
    
    private func removeItemFromInventory(itemName: String) -> Bool {
        return removeItemFromInventory(itemName: itemName, amount: 1)
    }

    private func removeItemFromInventory(itemName: String, amount: Int) -> Bool{
        let index = inventory.index(where: {$0.name == itemName})!
        if (inventory[index].amount >= amount) {
            inventory[index].amount -= amount
            
            inventoryManager.updateInventory(gameItems: inventory)
            return true;
        }
        return false;
    }

    func retrieveKnownLocations() -> Void {
        
    }
    
    func getDistanceToLocation(locationId: String, position: GameLocation) -> Int {
        if let location = retrieveLocationsDatabase()[locationId] {
            let distance = distanceCalculator.distance(lat1: position.latitude, lon1: position.longitude,
                                                       lat2: location.latitude, lon2: location.longitude,
                                                       unit: "K")
            if (distance.isNaN) {
                return 0;
            }
            if (distance.isInfinite) {
                return 1000;
            }
            return Int(distance * 1000)
        } else {
            return -1
        }
        
    }
    
    func updateCurrentLocation(playerPosition: GameLocation) {
        NSLog("Player is at (lat: \(playerPosition.latitude), lon \(playerPosition.longitude))")
        
        var positionIdentifier: String?
        for (location) in retrieveLocationsDatabase().keys {
            let distance = getDistanceToLocation(locationId: location, position: playerPosition)
            if (distance < 20) {
                positionIdentifier = location;
            }
            // NSLog("Distance to \(location) is \(distance)m")
        }
        
        if (positionIdentifier != currentLocationIdentifier) {
            currentLocationIdentifier = positionIdentifier
            NSLog("Location changed to \(currentLocationIdentifier ?? "nowhere")")
            delegate?.updateVisibleLocations(locations: retrieveVisibleLocations(curentLocationId: currentLocationIdentifier))
        }
    }
    
    func getDescriptionForItem(item: GameItem) -> String {
        return itemDescriptions[item.name] ?? "Wat een raar ding"
    }

    func getDescriptionForLocation(location: GameLocation) -> String {
        return locationDescriptions[location.name] ?? "Wat een raar ding"
    }

    // Home version
    func retrieveLocationsDatabase() -> [String: GameLocation] {
        return locations
    }
    
    func resetGame() {
        NSLog("Reset all game data")
        inventoryManager.updateInventory(gameItems: GameSetupStrocamp.loadItems())
        inventory = inventoryManager.loadInventory(cleanInventory: GameSetupStrocamp.loadItems())
    }
    
    func isCurrentLocation(location: GameLocation) -> Bool {
        if (currentLocationIdentifier == nil) {
            return false;
        }
        return currentLocationIdentifier == location.name
    }
    
    private func readPropertyList() {
        var format = PropertyListSerialization.PropertyListFormat.xml
        var plistData:[String:AnyObject] = [:]
        let plistPath:String? = Bundle.main.path(forResource: "GameData", ofType: "plist")!
        let plistXML = FileManager.default.contents(atPath: plistPath!)!
        
        do{ //convert the data to a dictionary and handle errors.
            plistData = try PropertyListSerialization.propertyList(from: plistXML, options: .mutableContainersAndLeaves,format: &format)as! [String:AnyObject]
            
            self.itemDescriptions = plistData["ItemDescriptions"] as! [String : String]
            self.locationDescriptions = plistData["LocationDescriptions"] as! [String: String]
        }
        catch{ // error condition
            print("Error reading plist: \(error), format: \(format)")
        }
    }
}

protocol GameManagerDelegate: class {
    func updateVisibleLocations(locations: [GameLocation])
}
