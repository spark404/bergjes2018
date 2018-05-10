//
//  GameManagerTests.swift
//  Bergjes2018Tests
//
//  Created by Hugo Trippaers on 08/05/2018.
//  Copyright © 2018 Hugo Trippaers. All rights reserved.
//

import XCTest

@testable import Bergjes2018

class GameManagerTests: XCTestCase {
    
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
    
    func testVisibleLocationsAtStart() {
        let gameManager = GameManager()
        gameManager.currentLocationId = "start"
        let result = gameManager.retrieveVisibleLocations()
        
        XCTAssertEqual(result.count, 2, "Expected 2 visible locations")
        XCTAssertTrue(result.contains(where: {$0.name == "start"}))
        XCTAssertTrue(result.contains(where: {$0.name == "boom"}))
    }

    func testVisibleLocationsAtBoomNotVisited() {
        let gameManager = GameManager()
        gameManager.currentLocationId = "boom"
        let result = gameManager.retrieveVisibleLocations()
        
        XCTAssertEqual(result.count, 2, "Expected 2 visible locations")
        XCTAssertTrue(result.contains(where: {$0.name == "start"}))
        XCTAssertTrue(result.contains(where: {$0.name == "boom"}))
    }

    func testVisibleLocationsAtBoomVisited() {
        let gameManager = GameManager()
        
        gameManager.currentLocationId = "boom"
        gameManager.registerVisit(locationId: "boom")
        
        let result = gameManager.retrieveVisibleLocations()
        
        XCTAssertEqual(result.count, 4, "Expected 4 visible locations")
        XCTAssertTrue(result.contains(where: {$0.name == "start"}))
        XCTAssertTrue(result.contains(where: {$0.name == "houthakkershut"}))
        XCTAssertTrue(result.contains(where: {$0.name == "koopman"}))
        XCTAssertTrue(result.contains(where: {$0.name == "boom"}))
    }
    
    func testStartInventory() {
        let gameManager = GameManager()
        
        let result = gameManager.retrieveBackpackContents();
        XCTAssertEqual(result.count, 2, "Expected 2 items in the backpack")
        XCTAssertTrue(result.contains(where: {$0.name == "Zakmes"}))
        XCTAssertTrue(result.contains(where: {$0.name == "Munt"}))
    }

    func testStartInventoryAfterReset() {
        let gameManager = GameManager()
        
        gameManager.resetGame()
        
        let result = gameManager.retrieveBackpackContents();
        XCTAssertEqual(result.count, 2, "Expected 2 items in the backpack")
        XCTAssertTrue(result.contains(where: {$0.name == "Zakmes"}))
        XCTAssertTrue(result.contains(where: {$0.name == "Munt"}))
    }
    
    func testCompleteGameRun() {
        let gameManager = GameManager()
        let locations = gameManager.retrieveLocationsDatabase()
        
        // Start of the game
        gameManager.currentLocationId = "boom";
        var visibleLocations = getGameLocationsAsList(allLocations: locations, ids: ["boom", "start"])
        assertVisibleLocations(actual: gameManager.retrieveVisibleLocations(), expected: visibleLocations)
        assertInventoryContains(inventory: gameManager.inventory, itemId: "Zakmes", amount: 1)
        assertInventoryContains(inventory: gameManager.inventory, itemId: "Munt", amount: 1)

        // Visit boom
        gameManager.registerVisit(locationId: gameManager.currentLocationId!)
        visibleLocations = getGameLocationsAsList(allLocations: locations, ids: ["boom", "start", "houthakkershut","koopman"])
        assertVisibleLocations(actual: gameManager.retrieveVisibleLocations(), expected: visibleLocations)
        
        // Visit houthakkershut
        gameManager.currentLocationId = "houthakkershut";
        gameManager.registerVisit(locationId: gameManager.currentLocationId!)
        visibleLocations = getGameLocationsAsList(allLocations: locations, ids: ["boom", "houthakkershut","koopman"])
        assertVisibleLocations(actual: gameManager.retrieveVisibleLocations(), expected: visibleLocations)
        assertInventoryContains(inventory: gameManager.inventory, itemId: "Ladder", amount: 1)
        
        // Use Ladder at houthakkershut
        XCTAssertNotNil(gameManager.attemptUse(itemToUse: gameManager.inventory.first(where: {$0.name == "Ladder"})!), "Should be possible to use Ladder")
        assertInventoryContains(inventory: gameManager.inventory, itemId: "Ladder", amount: 1)
        assertInventoryContains(inventory: gameManager.inventory, itemId: "Munt", amount: 2)
        
        // Use Ladder at boom
        gameManager.currentLocationId = "boom";
        XCTAssertNotNil(gameManager.attemptUse(itemToUse: gameManager.inventory.first(where: {$0.name == "Ladder"})!), "Should be possible to use Ladder")
        visibleLocations = getGameLocationsAsList(allLocations: locations, ids: ["boom", "start", "houthakkershut","koopman","rivier"])
        assertVisibleLocations(actual: gameManager.retrieveVisibleLocations(), expected: visibleLocations)

        // Use Zakmes at boom
        gameManager.currentLocationId = "boom";
        XCTAssertNotNil(gameManager.attemptUse(itemToUse: gameManager.inventory.first(where: {$0.name == "Zakmes"})!), "Should be possible to use Zakmes")
        XCTAssertNotNil(gameManager.attemptUse(itemToUse: gameManager.inventory.first(where: {$0.name == "Zakmes"})!), "Should be possible to use Zakmes")
        assertInventoryContains(inventory: gameManager.inventory, itemId: "Twijg", amount: 2)

    }
    
    func assertInventoryContains(inventory: [GameItem], itemId: String, amount: Int, file: StaticString = #file, line: UInt = #line) {
        if let item = inventory.first(where: {$0.name == itemId}) {
            XCTAssertEqual(amount, item.amount, "Expected \(amount) of \(itemId), but got \(item.amount)", file: file, line: line)
        } else {
            XCTFail("Inventory should contain an \(itemId)", file: file, line: line)
        }
    }
    
    func assertVisibleLocations(actual: [GameLocation], expected: [GameLocation], file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(actual.count, expected.count, "Expected location count is \(expected.count) but was \(actual.count)", file: file, line: line)
        
        expected.forEach { (expectedLocation) in
            XCTAssertTrue(actual.contains(where: {$0.name == expectedLocation.name}), "Expected location \(expectedLocation.name) not present", file: file, line: line)
        }
    }
    
    func getGameLocationsAsList(allLocations: [String: GameLocation], ids: [String]) -> [GameLocation] {
        return allLocations
            .filter({ids.contains($0.key)})
            .map({return $0.value})
            .sorted(by: {$0.name < $1.name}) as [GameLocation]
    }
        
}
