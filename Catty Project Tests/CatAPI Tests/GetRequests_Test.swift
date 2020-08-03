//
//  GetRequests_Test.swift
//  Catty Project Tests
//
//  Created by Сергей Коршунов on 01.08.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import XCTest
import Moya
@testable import Catty_Project

class GetRequests_Test: XCTestCase {
    
    private let provider = MoyaProvider<CatAPI>()
    
    func doTestRequest<T: Decodable>(_ requestType: CatAPI,
                                     jsonMapType: T.Type,
                                     testingResult: ((T) -> Void)? = nil) {
        
        let exp = expectation(description: "Wait for request")
        provider.request(requestType) { result in
            switch result {
            case .success(let response):
                do {
                    let successfulResults = try response.filterSuccessfulStatusCodes()

                    let jsonData = try successfulResults.map(T.self)
                    testingResult?(jsonData)
                } catch {
                    XCTFail("\(T.self): \(error.localizedDescription)")
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
    
    // MARK: - Testing get methods
    
    func testGetCateroriesList() {
        doTestRequest(.getCategoriesList, jsonMapType: [CatCategory].self) { categories in
            categories.forEach { XCTAssertFalse($0.name.isEmpty) }
        }
    }
    
    func testGetVotes() {
        doTestRequest(.getVotes, jsonMapType: [Vote].self)
    }
    
    func testGetFavourites() {
        doTestRequest(.getFavourites, jsonMapType: [FavouriteImage].self) { favImages in
            favImages.forEach { XCTAssertNotNil(URL(string: $0.image.url)) }
        }
    }
    
    func testGetImagesFromPage() {
        doTestRequest(.getImagesFromPage(Int.random(in: 0...5000)), jsonMapType: [CatImage].self)
    }
    
    func testGetImage() {
        let image_id = "Rkx3nYxZ8"
        doTestRequest(.getImage(image_id), jsonMapType: CatDetail.self) { catImage in
            XCTAssertEqual(image_id, catImage.id)
            XCTAssertNotNil(URL(string: catImage.url))
            XCTAssertNil(catImage.breeds)
        }
    }
    
    func testGetImageWithBreeds() {
        let image_id = "RfdGhgEf3"
        doTestRequest(.getImage(image_id), jsonMapType: CatDetail.self) { catImage in
            XCTAssertEqual(image_id, catImage.id)
            XCTAssertNotNil(URL(string: catImage.url))
            
            guard let breeds = catImage.breeds, !breeds.isEmpty else {
                XCTFail("Empty Breeds")
                return
            }
            
            breeds.forEach {
                // check urls
                if let cfa_url = $0.cfa_url { XCTAssertNotNil(URL(string: cfa_url)) }
                if let vetstreet_url = $0.vetstreet_url { XCTAssertNotNil(URL(string: vetstreet_url)) }
                if let wikipedia_url = $0.wikipedia_url { XCTAssertNotNil(URL(string: wikipedia_url)) }
                if let vcahospitals_url = $0.vcahospitals_url { XCTAssertNotNil(URL(string: vcahospitals_url)) }
                
                // check stars value
                XCTAssertTrue($0.adaptability.isInRange(1...5))
                XCTAssertTrue($0.affection_level.isInRange(1...5))
                XCTAssertTrue($0.dog_friendly.isInRange(1...5))
                XCTAssertTrue($0.energy_level.isInRange(1...5))
                XCTAssertTrue($0.intelligence.isInRange(1...5))
                XCTAssertTrue($0.social_needs.isInRange(1...5))
                XCTAssertTrue($0.stranger_friendly.isInRange(1...5))
                XCTAssertTrue($0.child_friendly.isInRange(1...5))
                XCTAssertTrue($0.health_issues.isInRange(1...5))
                XCTAssertTrue($0.grooming.isInRange(1...5))
                XCTAssertTrue($0.shedding_level.isInRange(1...5))
                XCTAssertTrue($0.vocalisation.isInRange(1...5))
                
                if let cat_friendly = $0.cat_friendly {
                    XCTAssertTrue(cat_friendly.isInRange(1...5))
                }
                
                // check marks value
                XCTAssertTrue($0.experimental.isInRange(0...1))
                XCTAssertTrue($0.hairless.isInRange(0...1))
                XCTAssertTrue($0.hypoallergenic .isInRange(0...1))
                XCTAssertTrue($0.natural.isInRange(0...1))
                XCTAssertTrue($0.rare.isInRange(0...1))
                XCTAssertTrue($0.rex.isInRange(0...1))
                XCTAssertTrue($0.short_legs.isInRange(0...1))
                XCTAssertTrue($0.suppressed_tail.isInRange(0...1))
            }
        }
    }
    
    func testGetUploadedImages() {
        doTestRequest(.getUploadedImages(0), jsonMapType: [CatImage].self)
    }
}
