//
//  CatAPI_GetRequests_Test.swift
//  Catty Project Tests
//
//  Created by Сергей Коршунов on 01.08.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import XCTest
import Moya
@testable import Catty_Project

class CatAPI_GetRequests_Test: XCTestCase {
    
    private let provider = MoyaProvider<CatAPI>()
    private let requestsTimeout: TimeInterval = 10
    
    func doTestRequest<T: Decodable>(_ requestType: CatAPI,
                                     jsonMapType: T.Type,
                                     testingResult: ((T?) -> Void)? = nil) {
        
        let exp = expectation(description: "Wait for request")
        provider.request(requestType) { result in
            switch result {
            case .success(let response):
                let successfulResults = try? response.filterSuccessfulStatusCodes()
                XCTAssertNotNil(successfulResults, "Response status code \(response.statusCode)")
                let jsonData = try? successfulResults?.map(T.self)
                XCTAssertNotNil(jsonData, "Fail on mapping json to type: \(T.self)")
                
                testingResult?(jsonData)
                
            case .failure(let error):
                XCTFail("Request fail: \(error.localizedDescription)")
            }
            exp.fulfill()
        }
        
        waitForExpectations(timeout: requestsTimeout) { error in
            if let error = error {
                XCTFail("Request timeout: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Testing get methods
    
    func testGetCateroriesList() {
        doTestRequest(.getCategoriesList, jsonMapType: [CatCategory].self) { categories in
            categories?.forEach { XCTAssertFalse($0.name.isEmpty) }
        }
    }
    
    func testGetVotes() {
        doTestRequest(.getVotes, jsonMapType: [Vote].self) { votes in
            votes?.forEach { XCTAssertTrue([0, 1].contains($0.value)) }
        }
    }
    
    func testGetFavourites() {
        doTestRequest(.getFavourites, jsonMapType: [FavouriteImage].self) { favImages in
            favImages?.forEach { XCTAssertNotNil(URL(string: $0.image.url)) }
        }
    }
    
    func testGetImagesFromPage() {
        
    }
    
    func testGetImage() {
        
    }

    func testGetUploadedImages() {
        
    }
    

    
    // MARK: - Testing vote methods
    
    func testVoteCreate() {
        debugPrint("vote created")
    }
    
    func testVoteDelete() {
        debugPrint("vote deleted")

    }

    // MARK: - Testing favourite methods
    
    func testFavouriteImageCreate() {
        
    }
    
    func testFavouriteImageDelete() {
        
    }

    // MARK: - Testing uploading methods

    func testUploadImage() {
        
    }
    
    func testUploadImageAnalysis() {
        
    }
    
    func testUploadImageDeletion() {
        
    }
}
