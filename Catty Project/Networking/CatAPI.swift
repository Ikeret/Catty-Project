//
//  CatAPI.swift
//  Catty Project
//
//  Created by Сергей Коршунов on 15.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import Moya
import Foundation

fileprivate let x_api_key = "f89e1171-9b7f-4923-81b2-4b014e783057"
fileprivate let pageLimit = 50

public enum CatAPI {
    case getCategoriesList
    
    case getVotes
    case vote(_ image_id: String, _ value: Int)
    
    case getFavourites(_ page: Int = 0)
    case markImageAsFavourite(_ image_id: String)
    case deleteImageFromFavourite(_ favourite_id: String)
    
    case getImagesFromPage(_ page: Int = 0, _ category_id: Int = 0)
    case getImage(_ image_id: String)
}

extension CatAPI: TargetType {
    public var baseURL: URL {
        return URL(string: "https://api.thecatapi.com/v1")!
    }
    
    public var path: String {
        switch self {
        case .getCategoriesList:
            return "/categories"
        case .getVotes, .vote:
            return "/votes"
        case .getFavourites, .markImageAsFavourite:
            return "/favourites/"
        case .deleteImageFromFavourite(let favourite_id):
            return "/favourites/\(favourite_id)"
        case .getImagesFromPage:
            return "/images/search"
        case .getImage(let image_id):
            return "/images/\(image_id)"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .getCategoriesList, .getVotes, .getFavourites, .getImage, .getImagesFromPage:
            return .get
        case .vote, .markImageAsFavourite:
            return .post
        case .deleteImageFromFavourite:
            return .delete
        }
    }
    
    public var sampleData: Data {
        return Data()
    }
    
    public var task: Task {
        let sub_id = User.sub_id
        switch self {
        case .getCategoriesList:
            return .requestPlain
        case .getVotes:
            return .requestParameters(parameters: ["sub_id": sub_id], encoding: URLEncoding.default)
        case .vote(let image_id, let value):
            return .requestParameters(parameters: ["image_id": image_id, "sub_id": sub_id, "value": value], encoding: JSONEncoding.default)
        case .getFavourites(let page):
            return .requestParameters(parameters: ["sub_id": sub_id, "limit": pageLimit, "page": page], encoding: URLEncoding.default)
        case .markImageAsFavourite(let image_id):
            return .requestParameters(parameters: ["image_id": image_id, "sub_id": sub_id], encoding: JSONEncoding.default)
        case .deleteImageFromFavourite(let favourite_id):
            return .requestParameters(parameters: ["favourite_id": favourite_id], encoding: JSONEncoding.default)
        case .getImagesFromPage(let page, let category_id):
            var params: [String: Any] = ["size": "med", "order": "RANDOM", "limit": pageLimit, "page": page, "format": "json"]
            if category_id != 0 { params["category_ids"] = category_id }
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .getImage(let image_id):
            return .requestParameters(parameters: ["image_id": image_id], encoding: URLEncoding.default)
        }
    }
    
    public var headers: [String : String]? {
        return ["x-api-key" : x_api_key]
    }
}

