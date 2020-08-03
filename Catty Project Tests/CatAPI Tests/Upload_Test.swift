//
//  Upload_Test.swift
//  Catty Project Tests
//
//  Created by Сергей Коршунов on 02.08.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import XCTest
import Moya
@testable import Catty_Project

class Upload_Test: XCTestCase {
    
    private let provider = MoyaProvider<CatAPI>()
    
    private static var image_id: String?
    
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
        
        waitForExpectations(timeout: 30) { error in
            if let error = error {
                XCTFail("Request timeout: \(error.localizedDescription)")
            }
        }
    }
    
    struct UploadResponse: Decodable {
        let url: String
    }
    
    func saveTempImage(imageName: String) -> URL {
        let imageData = UIImage(named: imageName)?.jpegData(compressionQuality: 0.8)
        
        let fileName = UUID().uuidString
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName + ".jpeg")
        FileManager.default.createFile(atPath: url.path, contents: imageData)
        return url
    }
    
    // MARK: - Testing uploading methods

    func testUploadImage() {
        let url = saveTempImage(imageName: "test")
        
        doTestRequest(.uploadImageFromURL(url), expectedStatusCode: 201) { response in
            do {
                let image_url = try response.map(UploadResponse.self).url
                if let id = URL(string: image_url)?.lastPathComponent.dropLast(4) {
                    Upload_Test.image_id = String(id)
                }
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testUploadImageNoCatOnImage() {
        let url = saveTempImage(imageName: "Shadow")

        doTestRequest(.uploadImageFromURL(url), expectedStatusCode: 400)
    }
    
    func testUploadImageAnalysis() {
        if let image_id = Upload_Test.image_id {
            doTestRequest(.getImageAnalysis(image_id), expectedStatusCode: 200) { response in
                do {
                    let analysis = try response.map([CatAnalysis].self).first!
                    
                    XCTAssertFalse(analysis.labels.isEmpty)
                    analysis.labels.forEach { XCTAssertFalse($0.Name.isEmpty) }
                } catch {
                    XCTFail(error.localizedDescription)
                }
            }
        } else {
            XCTFail("Image id is nil")
        }
    }
    
    func testUploadImageDelete() {
        if let image_id = Upload_Test.image_id {
            doTestRequest(.deleteUploadedImage(image_id), expectedStatusCode: 204)
        } else {
            XCTFail("Image id is nil")
        }
    }
}
