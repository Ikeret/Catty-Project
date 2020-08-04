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
            let nextButton = favButtons.element(boundBy: Int.random(in: 0...6))
            if !nextButton.isHittable { continue }
            
            let id = nextButton.identifier
            if Bool.random() {
                nextButton.tap()
                XCTAssertNotEqual(id, nextButton.identifier)
            } else {
                nextButton.doubleTap()
                XCTAssertEqual(id, nextButton.identifier)
            }
          
            if Bool.random() { app.swipeUp() }

        }
    }
    
    func testOpenDetail() {
        let catCollection = app.collectionViews["CatImagesCollection"]
        let catCells = catCollection.cells
        XCTAssertTrue(catCollection.isHittable)
        XCTAssertTrue(catCells["CatCell"].isHittable)
        
        for _ in 1...10 {
            catCells.element(boundBy: Int.random(in: 0...6)).tap()
            XCTAssertFalse(catCollection.isHittable)
            
            app.navigationBack()
            XCTAssertTrue(catCollection.isHittable)
            
            if Bool.random() { app.swipeUp() }
        }
        
        
    }
}
