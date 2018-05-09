//
//  ItemCombinationTests.swift
//  Bergjes2018Tests
//
//  Created by Hugo Trippaers on 09/05/2018.
//  Copyright © 2018 Hugo Trippaers. All rights reserved.
//

import XCTest
@testable import Bergjes2018

class ItemCombinationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Clear out persisted data
        let fileManager = FileManager()
        do {
            try fileManager.removeItem(at: Item.ArchiveURL)
        } catch {
            // Empty
        }
        
        do {
            try fileManager.removeItem(at: Location.ArchiveURL)
        } catch {
            // Emtpy
        }

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCombinationTwijgAndZakmes() {
        let gameManager = GameManager()
        
        gameManager.inventory.first(where: { $0.name == "Twijg"})!.amount += 1
        gameManager.inventory.first(where: { $0.name == "Touw"})!.amount += 1
        gameManager.inventoryManager.updateInventory(gameItems: gameManager.inventory)
        
        let combineResult = gameManager.attemptCombine(itemsToCombine: gameManager.inventory.filter { $0.name == "Twijg" || $0.name == "Touw" })
        
        XCTAssertNotNil(combineResult, "Twijg and Touw should be a valid combination")
        
        let result = gameManager.retrieveBackpackContents();
        XCTAssertEqual(result.count, 3, "Expected 3 items in the backpack")
        XCTAssertTrue(result.contains(where: {$0.name == "Zweep"}))
    }

}
