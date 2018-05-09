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
        
        do {
            try fileManager.removeItem(at: Action.ArchiveURL)
        } catch {
            // Emtpy
        }


    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCombinationTwijgAndTouw() {
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

    func testCombinationZakmesAndSmeerolie() {
        let gameManager = GameManager()
        
        gameManager.inventory.first(where: { $0.name == "Smeerolie"})!.amount += 1
        gameManager.inventoryManager.updateInventory(gameItems: gameManager.inventory)
        
        let combineResult = gameManager.attemptCombine(itemsToCombine: gameManager.inventory.filter { $0.name == "Zakmes" || $0.name == "Smeerolie" })
        
        XCTAssertNotNil(combineResult, "Zakmes and Smeerolie should be a valid combination")
        
        let result = gameManager.retrieveBackpackContents();
        XCTAssertEqual(result.count, 4, "Expected 4 items in the backpack")
        XCTAssertTrue(result.contains(where: {$0.name == "Schroevendraaier"}))
        XCTAssertTrue(result.contains(where: {$0.name == "Smeerolie"}))
        XCTAssertTrue(result.contains(where: {$0.name == "Zakmes"}))
    }

}
