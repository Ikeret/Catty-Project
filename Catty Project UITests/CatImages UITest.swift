//
//  CatImages UITest.swift
//  Catty Project UITests
//
//  Created by Сергей on 04.08.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import XCTest

class CatImages_UITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUp() {
        app.launch()
    }
    
    func testTapFavouriteButton() {
        let favButtons = app.collectionViews["CatImagesCollection"].cells.buttons
        
        for _ in 1...10 {
            guard let nextButton = favButtons.allElementsBoundByIndex.randomElement() else {
                continue
            }
            
            if !nextButton.isHittable { continue }
            
            let id = nextButton.identifier
            
            nextButton.tap()
            XCTAssertNotEqual(id, nextButton.identifier)
            
            if Bool.random() { app.swipeUp() }

        }
    }
    
    func testOpenDetail() {
        let catCollection = app.collectionViews["CatImagesCollection"]
        let catCells = catCollection.cells
        XCTAssertTrue(catCollection.isHittable)
        XCTAssertTrue(catCells["CatCell"].waitForExistence(timeout: 1))
        
        for _ in 1...10 {
            catCells.element(boundBy: Int.random(in: 0...6)).tap()
            XCTAssertFalse(catCollection.isHittable)
            
            app.navigationBack()
            XCTAssertTrue(catCollection.isHittable)
            
            if Bool.random() { app.swipeUp() }
        }
        
        
    }
    
    func testSearchFilters() {
        
        for _ in 1...10 {
            app.navigationBars.buttons["filterButton"].tap()
            
            if Bool.random() {
                app.segmentedControls.buttons.allElementsBoundByIndex.randomElement()?.tap()
            }
            
            if Bool.random() {
                app.switches.element.tap()
            }
            
            if Bool.random() {
                app.tables.cells.allElementsBoundByIndex.randomElement()?.tap()
            }
            
            if Bool.random() {
                app.buttons["Apply"].tap()
            } else {
                app.navigationBack()
            }
            
        }
        
        
        app.navigationBars.buttons["filterButton"].tap()
        app.tables.cells.firstMatch.tap()
        app.buttons["Apply"].tap()
        
    }
}
