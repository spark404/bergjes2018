//
//  LocationManager.swift
//  Bergjes2018
//
//  Created by Hugo Trippaers on 06/05/2018.
//  Copyright © 2018 Hugo Trippaers. All rights reserved.
//

import Foundation

class LocationManager {
    var locations: [Location]
    
    init() {
        locations = PersistenceManager.loadLocations() ?? []
        NSLog("Loaded \(locations.count) locations from static inventory")
    }
    
    func reinitialize(locations: [Location]) {
        PersistenceManager.storeLocations(locations: locations)
        self.locations = locations
    }
    
    func isVisible(locationId: String) -> Bool {
        if let index = locations.index(where: { $0.name == locationId}) {
            return locations[index].visible
        }
        return false
    }
    
    func setVisible(locationId: String, visible: Bool) {
        if let index = locations.index(where: { $0.name == locationId}) {
            locations[index].visible = true
            PersistenceManager.storeLocations(locations: locations)
        }
    }

    func isVisited(locationId: String) -> Bool {
        if let index = locations.index(where: { $0.name == locationId}) {
            return locations[index].visited
        }
        return false
    }
    
    func setVisited(locationId: String, visible: Bool) {
        if let index = locations.index(where: { $0.name == locationId}) {
            locations[index].visited = true
            PersistenceManager.storeLocations(locations: locations)
        }
    }

}
