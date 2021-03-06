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

    // For management
    var forceAllVisible: Bool = false

    var currentLocationId: String?
    var delegate: GameManagerDelegate?
    
    var locations: [String: GameLocation] = [:]
    var inventory: [GameItem] = []
    
    var itemDescriptions: [String: String] = [:]
    var locationDescriptions: [String: String] = [:]
    var itemUsage: [String : [String: Any]] = [:]
    var itemCombinations: [String: [String: Any]] = [:]
    var merchantPrices: [String: Int] = [:]
    var errorMessages: [String: [String: Any]] = [:]
    
    var distanceCalculator = DistanceCalculator()
    var inventoryManager = InventoryManager()
    var locationManager =  LocationManager()
    var actionManager = ActionManager()
    
    let gameSetup: GameSetup = GameSetupBushcamp()
    
    init() {
        readPropertyList()
        
        // Initialize when needed
        if (locationManager.locations.isEmpty) {
            NSLog("Initializing persisted location list")
            let locationList = gameSetup.loadLocations().mapValues({
                (gameLocation: GameLocation) -> Location in
                return Location(name: gameLocation.name, visible: false, visited: false)
            })
            locationManager.reinitialize(locations: Array(locationList.values))
            locationManager.setVisible(locationId: "start", visible: true)
            locationManager.setVisible(locationId: "boom", visible: true)
        }
        
        if inventoryManager.inventory.isEmpty {
            NSLog("Initializing persisted location list")
            inventory = inventoryManager.loadInventory(cleanInventory: gameSetup.loadItems())
            self.addItemToInventory(itemName: "Zakmes")
            self.addItemToInventory(itemName: "Munt")
        }

        // locations = GameSetupStrocamp.loadLocations()
        locations = gameSetup.loadLocations()
        inventory = inventoryManager.loadInventory(cleanInventory: gameSetup.loadItems())
        
        currentLocationId = "startup" // Fake location to force update at the start
    }
    
    func getMapHome() -> GameLocation {
        return gameSetup.getMapHome()
    }
    
    func retrieveVisibleLocations() -> [GameLocation] {
        var visibleLocations: [GameLocation] = [];
        
        if let identifier = currentLocationId,
            let currentLocation = retrieveLocationsDatabase()[identifier] {
            
            if (locationManager.isVisible(locationId: identifier)) {
                // Append self
                visibleLocations.append(currentLocation)
                
                retrieveLocationsDatabase()
                    .filter({$0.key != identifier}) // Filter self
                    .filter({isLocationVisibleFrom(fromLocation: currentLocation, toLocationId: $0.key)})
                    .filter({locationManager.isVisible(locationId: $0.key)})
                    .forEach {
                        NSLog("Adding \($0.value.name) to visible locations")
                        visibleLocations.append($0.value)
                    }
            }
        }
        
        // Add start if there are no locations to see
        if (visibleLocations.count == 0) {
            visibleLocations.append(retrieveLocationsDatabase()["start"]!)
        }
        return visibleLocations
    }
    
    // This function is called when play clicked on a location
    // perform any actions there that should be done once the player
    // visits a location and has read the description.
    func registerVisit(locationId: String) {
        if (locationManager.isVisited(locationId: locationId)) {
            NSLog("Already visited \(locationId), not triggering actions")
            return
        }
        
        locationManager.setVisited(locationId: locationId, visible: true)
        
        switch locationId {
        case "boom":
            locationManager.setVisible(locationId: "koopman", visible: true)
            locationManager.setVisible(locationId: "houthakkershut", visible: true)
        case "houthakkershut":
            addItemToInventory(itemName: "Ladder")
        case "kloofrand":
            addItemToInventory(itemName: "Munt", amount: 3)
        case "moeras":
            addItemToInventory(itemName: "Munt", amount: 4)
        default:
            break
        }
        
        delegate?.updateVisibleLocations(locations: retrieveVisibleLocations())
    }
    
    func retrieveBackpackContents() -> [GameItem] {
        return inventory.filter { $0.amount > 0}
    }
    
    func attemptCombine(itemsToCombine: [GameItem]) -> String? {
        if (itemsToCombine.count > 2) {
            return nil
        }
        
        let combinableItem1 = itemsToCombine[0].name
        let combinableItem2 = itemsToCombine[1].name
        NSLog("Attempt to use \(combinableItem1) with \(combinableItem2)")
        
        let result = itemCombinations
            .filter { (arg) -> Bool in
                let (_, value) = arg
                let itemName = value["item1"] as! String
                NSLog("Checking if \(combinableItem1) matches \(itemName)")
                return itemsToCombine.contains {$0.name == itemName }
            }
            .filter { (arg) -> Bool in
                let (_, value) = arg
                let itemName = value["item2"] as! String
                NSLog("Checking if \(combinableItem2) matches \(itemName)")
                return itemsToCombine.contains {$0.name == itemName }
            }
            .first
        
        if let foundCombination = result {
            if (!actionManager.isActionExecutable(actionId: foundCombination.key)) {
                NSLog("\(combinableItem1) with \(combinableItem2) is a valid combination \(foundCombination.key) but was already executed")
                return nil
            }
            
            NSLog("\(combinableItem1) with \(combinableItem2) is a valid combination \(foundCombination.key)")
            
            addItemToInventory(itemName: foundCombination.value["grantItem"] as! String)
            
            if foundCombination.value["removeItem1"] as! Bool {
                _ = removeItemFromInventory(itemName: foundCombination.value["item1"] as! String)
            }
            
            if foundCombination.value["removeItem2"] as! Bool {
                _ = removeItemFromInventory(itemName: foundCombination.value["item2"] as! String)
            }

            actionManager.registerActionExecution(actionId: foundCombination.key)
            return (foundCombination.value["description"] as! String)
        }

        return nil
    }
    
    func attemptUse(itemToUse: GameItem) -> String? {
        NSLog("Attempt to use \(itemToUse.name) at \(currentLocationId ?? "unknown location")")
        for itemAction in itemUsage.filter({$0.value["item"] as! String == itemToUse.name  }) {
            
            // Check if we can perform the action by checking the location
            if let locationId = itemAction.value["matchLocation"] as? String , currentLocationId != locationId {
                // Not possible to use item here
                continue
            }
            
            // TODO This might be counter intuitive later on?
            if (!locationManager.isVisited(locationId: currentLocationId!)) {
                continue
            }
            
            NSLog("Found action \(itemAction.key)")
            
            let repeatable: Bool = itemAction.value["repeatable"] as? Bool ?? false
            
            if (!actionManager.isActionExecutable(actionId: itemAction.key) && !repeatable) {
                NSLog("\(itemAction.key) is a valid usage but was already executed")
                return nil
            }

            // Perform the action
            if let grantedItem = itemAction.value["grantItem"] as? String {
                NSLog("Granting item \(grantedItem)")
                addItemToInventory(itemName: grantedItem)
            }
            
            // Perform the action
            if let visibleLocationId = itemAction.value["unlockLocation"] as? String {
                NSLog("Unlocking location \(visibleLocationId)")
                locationManager.setVisible(locationId: visibleLocationId, visible: true)
                delegate?.updateVisibleLocations(locations: retrieveVisibleLocations())
            }
            
            actionManager.registerActionExecution(actionId: itemAction.key)
            
            return (itemAction.value["description"] as! String)
        }
        
        return nil;
    }

    // Returns an error message from the list or de default error message
    // Parameters:
    //   identifier1: GameLocation identifier or GameAction identifier
    //   identifier2: GameLocation identifier or GameAction identifier
    // Returns:
    //   String: error message
    func getErrorMessageForAttempt(identifier1: String, identifier2: String?) -> String {
        if (identifier2 == nil || identifier2 == "startup") {
            return "Dat gaat hier niet lukken..."
        }
        
        let searchKey = "\(identifier1)-\(identifier2!)"
        let reversedKey = "\(identifier2!)-\(identifier1)"
        let result = errorMessages
            .filter { (arg) -> Bool in
                let (key, _) = arg
                return {key == searchKey || key == reversedKey}()
            }
            .first

        if let foundCombination = result {
            return foundCombination.value["errorMessage"] as! String
        }
        
        if isItem(identifier: identifier1),
            isItem(identifier: identifier2) {
            // Its a combination attempt
            return "Deze items kan je helaas niet combineren."
        } else {
            // Its a use attempt at a location
            return "Dit item kan je hier helaas niet gebruiken."
        }
    }
    
    private func isItem(identifier: String?) -> Bool {
        if let itemId = identifier {
            return self.inventory.contains {$0.name == itemId}
        } else {
            return false;
        }
    }
    
    private func isLocationVisibleFrom(fromLocation: GameLocation, toLocationId: String) -> Bool {
        return getVisibleLocationIdsFrom(fromLocation: fromLocation).contains(toLocationId)
    }
    
    // This defines the basic routing
    private func getVisibleLocationIdsFrom(fromLocation: GameLocation) -> [String] {
        switch fromLocation.name {
        case "start":
            return ["boom"]
        case "boom":
            return ["start", "koopman", "houthakkershut", "rivier"]
        case "koopman":
            return ["boom", "houthakkershut"]
        case "houthakkershut":
            return ["boom", "koopman"]
        case "rivier":
            return ["boom", "kloofrand", "moeras", "berg"]
        case "kloofrand":
            return ["rivier", "kloofbodem"]
        case "kloofbodem":
            return ["kloofrand"]
        case "moeras":
            return ["rivier"]
        case "berg":
            return Array(locations.keys)
        default:
            return ["start"];
        }
    }

    func addItemToInventory(itemName: String) {
        addItemToInventory(itemName: itemName, amount: 1)
    }

    func addItemToInventory(itemName: String, amount: Int) {
        let index = inventory.index(where: {$0.name == itemName})!
        inventory[index].amount += amount
        
        inventoryManager.updateInventory(gameItems: inventory)
    }

    func removeItemFromInventory(itemName: String) -> Bool {
        return removeItemFromInventory(itemName: itemName, amount: 1)
    }

    func removeItemFromInventory(itemName: String, amount: Int) -> Bool{
        let index = inventory.index(where: {$0.name == itemName})!
        if (inventory[index].amount >= amount) {
            inventory[index].amount -= amount
            
            inventoryManager.updateInventory(gameItems: inventory)
            return true;
        }
        return false;
    }

    private func getDistanceToLocation(locationId: String, position: GameLocation) -> Int {
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
        // NSLog("Gamesystem is at \"\(currentLocationId ?? "nowhere")\" ")
        
        var positionIdentifier: String?
        for (location) in retrieveLocationsDatabase().keys {
            let distance = getDistanceToLocation(locationId: location, position: playerPosition)
            if (distance < 20) {
                positionIdentifier = location;
            }
            // NSLog("Distance to \(location) is \(distance)m")
        }
        
        // Player is nowhere if the location is not visible
        if let position = positionIdentifier,
            !locationManager.isVisible(locationId: position) {
            positionIdentifier = nil
        }
        
        if (positionIdentifier != currentLocationId || force) {
            currentLocationId = positionIdentifier
            NSLog("Location changed to \(currentLocationId ?? "nowhere")")
            if (forceAllVisible) {
                // Management Override
                NSLog("Forced all visibility")
                delegate?.updateVisibleLocations(locations: Array(retrieveLocationsDatabase().values))
            } else {
                delegate?.updateVisibleLocations(locations: retrieveVisibleLocations())
            }
        }
    }
    
    func getDescriptionForItem(item: GameItem) -> String {
        return itemDescriptions[item.name] ?? "Wat een raar ding..."
    }

    func getDescriptionForLocation(location: GameLocation) -> String {
        return locationDescriptions[location.name] ?? "Here be dragons..."
    }

    // Home version
    func retrieveLocationsDatabase() -> [String: GameLocation] {
        return locations
    }
    
    func resetGame() {
        NSLog("Reset all game data")
        inventoryManager.updateInventory(gameItems: gameSetup.loadItems())
        inventory = inventoryManager.loadInventory(cleanInventory: gameSetup.loadItems())
        self.addItemToInventory(itemName: "Zakmes")
        self.addItemToInventory(itemName: "Munt")

        let locationList = gameSetup.loadLocations().mapValues({
            (gameLocation: GameLocation) -> Location in
            return Location(name: gameLocation.name, visible: false, visited: false)
        })
        locationManager.reinitialize(locations: Array(locationList.values))
        locationManager.setVisible(locationId: "start", visible: true)
        locationManager.setVisible(locationId: "boom", visible: true)
        
        locations = gameSetup.loadLocations()
        
        actionManager.resetActions()
        
        delegate?.updateVisibleLocations(locations: retrieveVisibleLocations())
    }
    
    func isCurrentLocation(location: GameLocation) -> Bool {
        if (currentLocationId == nil) {
            return false;
        }
        return currentLocationId == location.name
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
            self.itemUsage = plistData["ItemUsage"] as! [String: [String: Any]]
            self.itemCombinations = plistData["ItemCombinations"] as! [String: [String: Any]]
            self.merchantPrices = plistData["MerchantPrices"] as! [String: Int]
            self.errorMessages = plistData["ErrorMessages"] as! [String: [String: Any]]
        }
        catch{ // error condition
            print("Error reading plist: \(error), format: \(format)")
        }
    }
}

protocol GameManagerDelegate: class {
    func updateVisibleLocations(locations: [GameLocation])
}
