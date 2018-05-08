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
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
