//
//  VoteFavourite_Test.swift
//  Catty Project Tests
//
//  Created by Сергей Коршунов on 02.08.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import XCTest
import Moya
@testable import Catty_Project

class VoteFavourite_Test: XCTestCase {
    
    private let provider = MoyaProvider<CatAPI>()
    
    private let image_id = "Rkx3nYxZ8"
    
    private static var fav_id: Int?
    
    override class func setUp() {
        User.shared.registerUser(name: "test \(Date())")
    }
    
    override class func tearDown() {
        User.shared.logOut()
    }
    
    struct OperationResponse: Decodable {
        let id: Int
    }
    
    func doTestRequest(_ target: CatAPI, expectedStatusCode: Int) {
        let exp = expectation(description: "Wait for request")
        
        provider.request(target) { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.statusCode, expectedStatusCode)
                
                if VoteFavourite_Test.fav_id == nil {
                    VoteFavourite_Test.fav_id = try? response.map(OperationResponse.self).id
                }
                
            case .failure(let error):
                XCTFail("Request fail: \(error.localizedDescription)")
            }
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("Request timeout: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Testing favourite methods
    
    func testFavouriteImageCreate() {
        doTestRequest(.markImageAsFavourite(image_id), expectedStatusCode: 200)
    }
    
    func testFavouriteImageCreateDuplicate() {
        doTestRequest(.markImageAsFavourite(image_id), expectedStatusCode: 400)
    }
    
    func testFavouriteImageDelete() {
        if let fav_id = VoteFavourite_Test.fav_id {
            doTestRequest(.deleteImageFromFavourite(String(fav_id)), expectedStatusCode: 200)
        } else {
            XCTFail("Favourite id is nil")
        }
    }
    
    func testFavouriteImageDeleteDuplicate() {
        if let fav_id = VoteFavourite_Test.fav_id {
            doTestRequest(.deleteImageFromFavourite(String(fav_id)), expectedStatusCode: 400)
        } else {
            XCTFail("Favourite id is nil")
        }
    }
    
    // MARK: - Testing vote methods
    
    func testVoteCreate() {
        let exp = expectation(description: "Wait for request")
        
        provider.request(.vote(image_id, Int.random(in: 0...1))) { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.statusCode, 200)
                
            case .failure(let error):
                XCTFail("Request fail: \(error.localizedDescription)")
            }
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("Request timeout: \(error.localizedDescription)")
            }
        }
    }
}
