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
    
    func doTestRequest(_ target: CatAPI, expectedStatusCode: Int, responseHandler: ((Response) -> Void)? = nil) {
        let exp = expectation(description: "Wait for request")
        
        provider.request(target) { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.statusCode, expectedStatusCode)
                
                responseHandler?(response)
                
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
    
    struct FavouriteResponse: Decodable {
        let id: Int
    }

    // MARK: - Testing favourite methods
    
    func testFavouriteImageCreate() {
        doTestRequest(.markImageAsFavourite(image_id), expectedStatusCode: 200) { response in
            if VoteFavourite_Test.fav_id == nil {
                VoteFavourite_Test.fav_id = try? response.map(FavouriteResponse.self).id
            }
        }
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
        doTestRequest(.vote(image_id, Int.random(in: 0...1)), expectedStatusCode: 200)
    }
}
