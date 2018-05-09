//
//  Action.swift
//  Bergjes2018
//
//  Created by Hugo Trippaers on 09/05/2018.
//  Copyright © 2018 Hugo Trippaers. All rights reserved.
//

import Foundation
import os.log

struct ActionPropertyKey {
    static let name = "name"
    static let executed = "executed"
}

class Action: NSObject, NSCoding {
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("actions")
    
    var name: String
    var executed: Int
    
    init(name: String, executed: Int) {
        self.name = name
        self.executed = executed
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: ActionPropertyKey.name)
        aCoder.encode(executed, forKey: ActionPropertyKey.executed)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: ActionPropertyKey.name) as? String else {
            os_log("Unable to decode the name for an location object.", log: OSLog.default, type: .debug)
            return nil
        }
        let executed = aDecoder.decodeInteger(forKey: ActionPropertyKey.executed)
        
        self.init(name: name, executed: executed)
    }
    
}
