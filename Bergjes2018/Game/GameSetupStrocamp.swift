//
//  GameSetupStrocamp.swift
//  Bergjes2018
//
//  Created by Hugo Trippaers on 06/05/2018.
//  Copyright © 2018 Hugo Trippaers. All rights reserved.
//

import Foundation

class GameSetupStrocamp: GameSetup {
    var filetype: String
    var reference: String
    var maphome: [String: Double]
    var maplocations: [String: [String: Any]]
    
    init() {
        var format = PropertyListSerialization.PropertyListFormat.xml
        var plistData:[String:AnyObject] = [:]
        let plistPath:String? = Bundle.main.path(forResource: "locations_strocamp", ofType: "plist")!
        let plistXML = FileManager.default.contents(atPath: plistPath!)!
        
        do{ //convert the data to a dictionary and handle errors.
            plistData = try PropertyListSerialization.propertyList(from: plistXML, options: .mutableContainersAndLeaves,format: &format)as! [String:AnyObject]
            
            self.filetype = plistData["type"] as! String
            self.reference = plistData["reference"] as! String
            self.maphome = plistData["maphome"] as! [String: Double]
            self.maplocations = plistData["locations"] as! [String: [String: Any]]
        }
        catch{ // error condition
            print("Error reading plist: \(error), format: \(format)")
            // TODO we can do better than this
            self.filetype = "error"
            self.reference = "error"
            self.maplocations = [String: [String: Any]]()
            self.maphome = [String: Double]()
        }
    }
    
    func getMapHome() -> GameLocation {
        return GameLocation(name: "maphome", latitude: maphome["latitude"]!, longitude: maphome["longitude"]!)
    }
    
    func loadLocations() -> [String: GameLocation] {
        var locations: [String: GameLocation] = [:]
        
        maplocations.forEach { (kvpair) in
            let (key, value) = kvpair
            let location = GameLocation(name: key, latitude: value["latitude"] as! Double,
                                        longitude: value["longitude"] as! Double, imageReference: value["name"] as! String)
            locations[key] = location;
        }
        
        // FIXME
        locations["start"]?.imageReference = nil

        return locations
    }
    
    func loadItems() -> [GameItem] {
        var items: [GameItem] = []
        items.append(GameItem(name: "Zakmes", imageReference: "01. Zakmes"))
        items.append(GameItem(name: "Munt", imageReference: "02. Munt"))
        items.append(GameItem(name: "Tak", imageReference: "03. Twijg"))
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
