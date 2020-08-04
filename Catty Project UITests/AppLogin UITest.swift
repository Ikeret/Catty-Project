//
//  AppLogin UITest.swift
//  Catty Project UITests
//
//  Created by Сергей on 04.08.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import XCTest

class AppLogin_UITest: XCTestCase {
    
    let app = XCUIApplication()
    
    func login() {
        let loginTF = app.textFields["loginTextField"]
        let loginButton = app.buttons["loginButton"]
        
        XCTAssert(loginTF.isHittable)
        XCTAssert(loginButton.isHittable)
        
        XCTAssertFalse(loginButton.isEnabled)
        
        loginTF.tap()
        loginTF.typeText("Se")
        XCTAssertFalse(loginButton.isEnabled)

        loginTF.typeText("r")
        XCTAssertTrue(loginButton.isEnabled)
        
        
        app.keys["delete"].press(forDuration: 1)
        
        XCTAssertFalse(loginButton.isEnabled)
        
        loginTF.typeText("Sergey")
        
        XCTAssertTrue(loginButton.isEnabled)
        loginButton.tap()
        
        XCTAssertFalse(loginTF.exists)
        XCTAssertFalse(loginButton.exists)
    }
    
    func testLogin() {
        app.launchArguments.append("user.logOut")
        app.launch()
        
        login()
    }
    
    func testLogout() {
        app.launch()
        
        let logOutButton = app.navigationBars.element.buttons["logOutButton"]
        XCTAssertTrue(logOutButton.isHittable)
        
        logOutButton.tap()
        XCTAssertFalse(logOutButton.exists)
        XCTAssertFalse(app.collectionViews.firstMatch.exists)
        
        login()
    }
}
