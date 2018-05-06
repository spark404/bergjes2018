//
//  Item.swift
//  Bergjes2018
//
//  Created by Hugo Trippaers on 06/05/2018.
//  Copyright © 2018 Hugo Trippaers. All rights reserved.
//

import Foundation
import os.log

struct ItemPropertyKey {
    static let name = "name"
    static let amount = "amount"
}

class Item: NSObject, NSCoding {
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("items")
    
    var name: String
    var amount: Int
    
    init(name: String, amount: Int) {
        self.name = name;
        self.amount = amount;
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: ItemPropertyKey.name)
        aCoder.encode(amount, forKey: ItemPropertyKey.amount)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: ItemPropertyKey.name) as? String else {
            os_log("Unable to decode the name for an inventory object.", log: OSLog.default, type: .debug)
            return nil
        }
        let amount = aDecoder.decodeInteger(forKey: ItemPropertyKey.amount)
        
        self.init(name: name, amount: amount)
    }
}
