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
    var itemUsage: [[String: Any]] = []
    
    var distanceCalculator = DistanceCalculator()
    var inventoryManager = InventoryManager()
    var locationManager =  LocationManager()
    
    private init() {
        readPropertyList()
        
        // Initialize when needed
        if (locationManager.locations.count == 0) {
            NSLog("Initializing persisted location list")
            let locationList = GameSetupStrocamp.loadLocations().mapValues({
                (gameLocation: GameLocation) -> Location in
                return Location(name: gameLocation.name, visible: false, visited: false)
            })
            locationManager.reinitialize(locations: Array(locationList.values))
        }

        locations = GameSetupStrocamp.loadLocations()
        inventory = inventoryManager.loadInventory(cleanInventory: GameSetupStrocamp.loadItems())
    }
    
    func retrieveVisibleLocations(currentLocationId: String?) -> [GameLocation] {
        var visibleLocations: [GameLocation] = [];
        
        if let identifier = currentLocationId,
            let currentLocation = retrieveLocationsDatabase()[identifier] {
            
            if (locationManager.isVisible(locationId: identifier)) {
                // Append self
                visibleLocations.append(currentLocation)
                
                for gameLocation in retrieveLocationsDatabase().values {
                    if (isLocationVisibleFrom(fromLocation: currentLocation, location: gameLocation)) {
                        visibleLocations.append(gameLocation)
                    }
                }
            }
        }
        
        // Add start if there are no locations to see
        if (visibleLocations.count == 0) {
            visibleLocations.append(retrieveLocationsDatabase()["start"]!)
        }
        return visibleLocations
    }
    
    func isLocationVisibleFrom(fromLocation: GameLocation, location: GameLocation) -> Bool {
        NSLog("Visibility check from \(fromLocation.name) to \(location.name)")
        if (location.name == "start") {
            return true // Start is always visible
        }
        
        if (!locationManager.isVisible(locationId: location.name)) {
            NSLog("\(location.name) isn't discovered yet")
            return false; // Location is not discovered yet
        }
        
        switch fromLocation.name {
        case "start":
            return ["boom"].contains(location.name)
        case "boom":
            return ["koopman", "houthakkershut", "rivier"].contains(location.name)
        case "koopman":
            return ["boom", "houthakkershut"].contains(location.name)
        case "houthakkershut":
            return ["boom", "koopman"].contains(location.name)
        case "rivier":
            return ["boom", "kloofrand", "moeras"].contains(location.name)
        case "kloofrand":
            return ["rivier", "kloofbodem"].contains(location.name)
        case "kloofbodem":
            return ["kloofrand"].contains(location.name)
        case "moeras":
            return ["rivier"].contains(location.name)
        case "berg":
            return true
        default:
            return false;
        }
    }
    
    func getColorForLocation(location: GameLocation) -> UIColor {
        if (location.name == currentLocationIdentifier) {
            return UIColor.blue;
        }
        
        return UIColor.red;
    }
    
    // This function is called when play clicked on a location
    // perform any actions there that should be done once the player
    // visits a location and has read the description.
    func registerVisit(location: GameLocation) {
        if (locationManager.isVisited(locationId: location.name)) {
            NSLog("Already visited \(location.name), not triggering actions")
        }
        
        locationManager.setVisited(locationId: location.name, visible: true)
        
        switch location.name {
        case "boom":
            locationManager.setVisible(locationId: "koopman", visible: true)
            locationManager.setVisible(locationId: "houthakkershut", visible: true)
        case "houthakkershut":
            addItemToInventory(itemName: "Ladder")
        default:
            break
        }
        
        delegate?.updateVisibleLocations(locations: retrieveVisibleLocations(currentLocationId: currentLocationIdentifier))
    }
    
    func retrieveBackpackContents() -> [GameItem] {
        return inventory
    }
    
    func attemptCombine(itemsToCombine: [GameItem]) -> String? {
        if (itemsToCombine.count > 2) {
            return nil
        }
        
        NSLog("Attempt to use \(itemsToCombine[0].name) with \(itemsToCombine[1].name)")
        
        if itemsToCombine.contains(where: { $0.name == "Motor" }) &&
            itemsToCombine.contains(where: { $0.name == "Schroef" }) {
            
            removeItemFromInventory(itemName: itemsToCombine[0].name)
            removeItemFromInventory(itemName: itemsToCombine[1].name)
            addItemToInventory(itemName: "Schroefmotor")
            
            return "FIXME Uitleg nodig"
        }
        
        return nil
    }
    
    func attemptUse(itemToUse: GameItem) -> String? {
        var removeItem: Bool = false
        
        for itemAction in itemUsage.filter({$0["item"] as! String == itemToUse.name  }) {
            
            // Check if we can perform the action by checking the location
            if let locationId = itemAction["matchLocation"] as? String , currentLocationIdentifier != locationId {
                // Not possible to use item here
                continue
            }
            
            // Perform the action
            if let grantedItem = itemAction["grantItem"] as? String {
                addItemToInventory(itemName: grantedItem)
            }

            // Perform the action
            if let visibleLocationId = itemAction["unlockLocation"] as? String {
                locationManager.setVisible(locationId: visibleLocationId, visible: true)
                delegate?.updateVisibleLocations(locations: retrieveVisibleLocations(currentLocationId: currentLocationIdentifier))
            }

            // Set the remove flag if needed
            if let shouldRemoveItem = itemAction["removeItem"] as? Bool, shouldRemoveItem {
                    removeItemFromInventory(itemName: itemToUse.name)
            }
            
            return (itemAction["description"] as! String)
        }
        
        return nil;
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
    
    func updateCurrentLocation(playerPosition: GameLocation ) {
        self.updateCurrentLocation(playerPosition: playerPosition, force: false)
    }
    
    func updateCurrentLocation(playerPosition: GameLocation, force: Bool) {
        // NSLog("Player is at (lat: \(playerPosition.latitude), lon \(playerPosition.longitude))")
        
        var positionIdentifier: String?
        for (location) in retrieveLocationsDatabase().keys {
            let distance = getDistanceToLocation(locationId: location, position: playerPosition)
            if (distance < 20) {
                positionIdentifier = location;
            }
            // NSLog("Distance to \(location) is \(distance)m")
        }
        
        if (positionIdentifier != currentLocationIdentifier || force) {
            currentLocationIdentifier = positionIdentifier
            NSLog("Location changed to \(currentLocationIdentifier ?? "nowhere")")
            delegate?.updateVisibleLocations(locations: retrieveVisibleLocations(currentLocationId: currentLocationIdentifier))
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
        
        let locationList = GameSetupStrocamp.loadLocations().mapValues({
            (gameLocation: GameLocation) -> Location in
            return Location(name: gameLocation.name, visible: false, visited: false)
        })
        locationManager.reinitialize(locations: Array(locationList.values))
        locationManager.setVisible(locationId: "start", visible: true)
        locationManager.setVisible(locationId: "boom", visible: true)
        
        locations = GameSetupStrocamp.loadLocations()
        
        delegate?.updateVisibleLocations(locations: retrieveVisibleLocations(currentLocationId: currentLocationIdentifier))
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
            self.itemUsage = plistData["ItemUsage"] as! [[String: Any]]
        }
        catch{ // error condition
            print("Error reading plist: \(error), format: \(format)")
        }
    }
}

protocol GameManagerDelegate: class {
    func updateVisibleLocations(locations: [GameLocation])
}
