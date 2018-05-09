//
//  GameSetupStrocamp.swift
//  Bergjes2018
//
//  Created by Hugo Trippaers on 06/05/2018.
//  Copyright © 2018 Hugo Trippaers. All rights reserved.
//

import Foundation

class GameSetupStrocamp {
    private init() {
        // Empty
    }
    
    static func loadLocations() -> [String: GameLocation] {
        var locations: [String: GameLocation] = [:]
        
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

        return locations
    }
    
    static func loadItems() -> [GameItem] {
        var items: [GameItem] = []
        items.append(GameItem(name: "Zakmes", imageReference: "01. Zakmes"))
        items.append(GameItem(name: "Munt", imageReference: "02. Munt"))
        items.append(GameItem(name: "Twijg", imageReference: "03. Twijg"))
        items.append(GameItem(name: "Touw", imageReference: "04. Touw"))
        items.append(GameItem(name: "Lemmet", imageReference: "05. Lemmet"))
        items.append(GameItem(name: "Duikbril", imageReference: "06. Duikbril"))
        items.append(GameItem(name: "Smeerolie", imageReference: "07. Smeerolie"))
        items.append(GameItem(name: "Kapmes", imageReference: "08. Kapmes"))
        items.append(GameItem(name: "Ladder", imageReference: "09. Ladder"))
        items.append(GameItem(name: "Kano", imageReference: "10. Kano"))
        items.append(GameItem(name: "Motor", imageReference: "11. Motor"))
        items.append(GameItem(name: "Schroef", imageReference: "12. Schroef"))
        items.append(GameItem(name: "Zweep", imageReference: "13. Zweep"))
        items.append(GameItem(name: "Schroevendraaier", imageReference: "14. Schroevendraaier"))
        items.append(GameItem(name: "Schroefmotor", imageReference: "15. Schroefmotor"))
        items.append(GameItem(name: "Motorboot", imageReference: "16. Motorboot"))
        
        return items
    }
}
