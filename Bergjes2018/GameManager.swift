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
    
    private init() {
        // Strocamp set
        locations["start"] = GameLocation(name: "start",
                                          latitude: 52.034280, longitude: 5.151333)
        locations["boom"] = GameLocation(name: "boom",
                                         latitude: 52.034017, longitude: 5.150460,
                                         imageReference: "Boom")
        locations["houthakkershut"] =  GameLocation(name: "houthakkershut",
                                                    latitude: 52.033655, longitude: 5.150145,
                                                    imageReference: "Houthakkershut")
        locations["koopman"] = GameLocation(name: "koopman",
                                            latitude: 52.032535, longitude: 5.150588,
                                            imageReference: "Koopman")
        locations["rivier"] = GameLocation(name: "rivier",
                                           latitude: 52.032490, longitude: 5.149937,
                                           imageReference: "Rivier")
        locations["kloofrand"] = GameLocation(name: "kloofrand",
                                              latitude: 52.032730, longitude: 5.149270,
                                              imageReference: "KloofRand")
        locations["kloofbodem"] = GameLocation(name: "kloofbodem",
                                               latitude: 52.033210, longitude: 5.149109,
                                               imageReference: "KloofBodem")
        locations["moeras"] = GameLocation(name: "moeras",
                                           latitude: 52.033866, longitude: 5.148644,
                                           imageReference: "Moeras")
        locations["berg"] = GameLocation(name: "berg",
                                         latitude: 52.033870, longitude: 5.149835,
                                         imageReference: "Berg")
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
    
    // Home version
    func retrieveLocationsDatabase() -> [String: GameLocation] {
        return locations
    }
}

protocol GameManagerDelegate: class {
    func updateVisibleLocations(locations: [GameLocation])
}
