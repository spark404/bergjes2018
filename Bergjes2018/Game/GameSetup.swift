//
//  GameSetup.swift
//  Bergjes2018
//
//  Created by Hugo Trippaers on 22/09/2018.
//  Copyright © 2018 Hugo Trippaers. All rights reserved.
//

import Foundation

protocol GameSetup {
    func loadLocations() -> [String: GameLocation]
    func loadItems() -> [GameItem]
    func getMapHome() -> GameLocation
}
