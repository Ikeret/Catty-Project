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
private let pageLimit = 50

public enum CatAPI {
    case getCategoriesList

    case getVotes
    case vote(_ image_id: String, _ value: Int)

    case getFavourites
    case markImageAsFavourite(_ image_id: String)
    case deleteImageFromFavourite(_ favourite_id: String)

    case getImagesFromPage(_ page: Int)
    case getImage(_ image_id: String)

    case getUploadedImages(_ page: Int)
    case uploadImageFromURL(_ url: URL)
    case deleteUploadedImage(_ image_id: String)
    case getImageAnalysis(_ image_id: String)
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
        case .getUploadedImages:
            return "/images/"
        case .uploadImageFromURL:
            return "/images/upload"
        case .deleteUploadedImage(let image_id):
            return "/images/\(image_id)"
        case .getImageAnalysis(let image_id):
            return "images/\(image_id)/analysis"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .getCategoriesList, .getVotes, .getFavourites, .getImage, .getImagesFromPage, .getUploadedImages, .getImageAnalysis:
            return .get
        case .vote, .markImageAsFavourite, .uploadImageFromURL:
            return .post
        case .deleteImageFromFavourite, .deleteUploadedImage:
            return .delete
        }
    }

    public var sampleData: Data {
        return Data()
    }

    public var task: Task {
        let sub_id = User.shared.sub_id
        switch self {
        case .getCategoriesList, .deleteImageFromFavourite, .deleteUploadedImage, .getImageAnalysis:
            return .requestPlain
        case .getVotes:
            return .requestParameters(parameters: ["sub_id": sub_id],
                                      encoding: URLEncoding.default)
        case .vote(let image_id, let value):
            return .requestParameters(parameters: ["image_id": image_id,
                                                   "sub_id": sub_id,
                                                   "value": value],
                                      encoding: JSONEncoding.default)
        case .getFavourites:
            return .requestParameters(parameters: ["sub_id": sub_id],
                                      encoding: URLEncoding.default)
        case .markImageAsFavourite(let image_id):
            return .requestParameters(parameters: ["image_id": image_id,
                                                   "sub_id": sub_id],
                                      encoding: JSONEncoding.default)
        case .getImagesFromPage(let page):
            var params: [String: Any] = ["size": "full",
                                         "order": User.shared.sorting,
                                         "limit": pageLimit,
                                         "page": page,
                                         "format": "json"]
            if User.shared.categoryId != 0 { params["category_ids"] = User.shared.categoryId }
            if User.shared.onlyGif { params["mime_types"] = "gif" }
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
        case .getImage(let image_id):
            return .requestParameters(parameters: ["image_id": image_id],
                                      encoding: URLEncoding.default)
        case .getUploadedImages(let page):
            return .requestParameters(parameters: ["order": "DESC",
                                                   "limit": pageLimit,
                                                   "page": page,
                                                   "sub_id": sub_id],
                                      encoding: URLEncoding.default)
        case .uploadImageFromURL(let url):
            let imageData = MultipartFormData(provider: .file(url), name: "file")
            let descriptionData = MultipartFormData(provider: .data(sub_id.data(using: .utf8)!), name: "sub_id")

            return .uploadMultipart([imageData, descriptionData])
        }
    }

    public var headers: [String: String]? {
        switch self {
        case .uploadImageFromURL:
            return ["x-api-key": x_api_key, "Content-Type": "multipart/form-data"]
        default:
            return ["x-api-key": x_api_key]
        }
    }
}
