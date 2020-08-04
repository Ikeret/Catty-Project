//
//  XCUIApplication.swift
//  Catty Project UITests
//
//  Created by Сергей on 04.08.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import XCTest

extension XCUIApplication {
    
    func swipeUp(times: Int) {
        
        for _ in 0..<times { swipeUp() }
        
    }
    
    func navigationBack() {
        navigationBars.buttons.firstMatch.tap()
    }
}
