//
//  Location.swift
//  Bergjes2018
//
//  Created by Hugo Trippaers on 06/05/2018.
//  Copyright © 2018 Hugo Trippaers. All rights reserved.
//

import Foundation
import os.log

struct LocationPropertyKey {
    static let name = "name"
    static let visible = "visible"
    static let visited = "visited"
}

class Location: NSObject, NSCoding {
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("locations")

    var name: String
    var visible: Bool
    var visited: Bool
    
    init(name: String, visible: Bool, visited: Bool) {
        self.name = name
        self.visible = visible
        self.visited = visited
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: LocationPropertyKey.name)
        aCoder.encode(visible, forKey: LocationPropertyKey.visible)
        aCoder.encode(visited, forKey: LocationPropertyKey.visited)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: LocationPropertyKey.name) as? String else {
            os_log("Unable to decode the name for an location object.", log: OSLog.default, type: .debug)
            return nil
        }
        let visible = aDecoder.decodeBool(forKey: LocationPropertyKey.visible)
        let visited = aDecoder.decodeBool(forKey: LocationPropertyKey.visited)
        
        self.init(name: name, visible: visible, visited: visited)
    }

}
