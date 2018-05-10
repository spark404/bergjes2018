//
//  GameLocation.swift
//  Bergjes2018
//
//  Created by Hugo Trippaers on 29/04/2018.
//  Copyright © 2018 Hugo Trippaers. All rights reserved.
//

import Foundation

class GameLocation {
    
    var name: String
    var latitude: Double
    var longitude: Double
    var imageReference: String?
    
    init(name: String, latitude: Double, longitude: Double) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }

    init(name: String, latitude: Double, longitude: Double, imageReference: String) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.imageReference = imageReference
    }

}

extension GameLocation: Equatable {
    static func == (lhs: GameLocation, rhs: GameLocation) -> Bool {
        return lhs.name == rhs.name
    }
    
    
}
