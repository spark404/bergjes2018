//
//  GameItem.swift
//  Bergjes2018
//
//  Created by Hugo Trippaers on 06/05/2018.
//  Copyright © 2018 Hugo Trippaers. All rights reserved.
//

import Foundation

class GameItem {
    var name: String
    var amount: Int
    var imageReference: String
    
    init(name: String, imageReference: String) {
        self.name = name
        self.imageReference = imageReference
        self.amount = 0
    }

    init(name: String, imageReference: String, amount: Int) {
        self.name = name
        self.imageReference = imageReference
        self.amount = amount
    }
}
