//
//  ItemUsageTests.swift
//  Bergjes2018Tests
//
//  Created by Hugo Trippaers on 09/05/2018.
//  Copyright © 2018 Hugo Trippaers. All rights reserved.
//

import XCTest
@testable import Bergjes2018

class ItemUsageTests: XCTestCase {
    
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
    
    func testUseLadderAtHut() {
        let gameManager = GameManager()
        
        gameManager.currentLocationId = "houthakkershut"
        gameManager.locationManager.setVisible(locationId: "houthakkershut", visible: true)
        gameManager.locationManager.setVisited(locationId: "houthakkershut", visible: true)

        gameManager.inventory.first(where: { $0.name == "Ladder"})!.amount += 1
        gameManager.inventoryManager.updateInventory(gameItems: gameManager.inventory)

        let useResult = gameManager.attemptUse(itemToUse: gameManager.inventory.first { $0.name == "Ladder" }!)
        
        XCTAssertNotNil(useResult, "Ladder at Houthakkershut should be a valid usage")
        
        let result = gameManager.retrieveBackpackContents();
        XCTAssertEqual(result.count, 3, "Expected 3 items in the backpack")
        XCTAssertTrue(result.contains(where: {$0.name == "Munt"}))
        XCTAssertEqual(result.first(where: {$0.name == "Munt"})!.amount, 2)
    }

    func testRepeatedUseLadderAtHut() {
        let gameManager = GameManager()
        
        gameManager.currentLocationId = "houthakkershut"
        gameManager.locationManager.setVisible(locationId: "houthakkershut", visible: true)
        gameManager.locationManager.setVisited(locationId: "houthakkershut", visible: true)
        
        gameManager.inventory.first(where: { $0.name == "Ladder"})!.amount += 1
        gameManager.inventoryManager.updateInventory(gameItems: gameManager.inventory)
        
        var useResult = gameManager.attemptUse(itemToUse: gameManager.inventory.first { $0.name == "Ladder" }!)
        XCTAssertNotNil(useResult, "Ladder at Houthakkershut should be a valid usage")

        useResult = gameManager.attemptUse(itemToUse: gameManager.inventory.first { $0.name == "Ladder" }!)
        XCTAssertNil(useResult, "Ladder at Houthakkershut shouldn't be usable a second time")

        let result = gameManager.retrieveBackpackContents();
        XCTAssertEqual(result.count, 3, "Expected 3 items in the backpack")
        XCTAssertTrue(result.contains(where: {$0.name == "Munt"}))
        XCTAssertEqual(result.first(where: {$0.name == "Munt"})!.amount, 2)
    }

    func testRepeatUseZakmesAtBoom() {
        let gameManager = GameManager()
        
        gameManager.currentLocationId = "boom"
        gameManager.locationManager.setVisited(locationId: "boom", visible: true)

        var useResult = gameManager.attemptUse(itemToUse: gameManager.inventory.first { $0.name == "Zakmes" }!)
        XCTAssertNotNil(useResult, "Zakmes at Boom should be a valid usage")

        useResult = gameManager.attemptUse(itemToUse: gameManager.inventory.first { $0.name == "Zakmes" }!)
        XCTAssertNotNil(useResult, "Zakmes at Boom should be a valid usage")

        let result = gameManager.retrieveBackpackContents();
        XCTAssertEqual(result.count, 3, "Expected 3 items in the backpack")
        XCTAssertTrue(result.contains(where: {$0.name == "Tak"}))
        XCTAssertEqual(result.first(where: {$0.name == "Tak"})?.amount, 2)
    }

}
