//
//  CatCellViewModel.swift
//  Catty Project
//
//  Created by Сергей Коршунов on 19.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import RxSwift
import Foundation

class CatCellViewModel {
    let id: String
    let image_url: URL?
    var isFavourite: Bool
    var favouriteId: String

    var favImageName: String {
        isFavourite ? "heart.fill" : "heart"
    }
    
    let requestManager = RequestManager()
    let repository: CatImagesRepository?

    init(id: String, image_url: String, favouriteId: String, repository: CatImagesRepository? = nil, isFavourite: Bool = false) {
        self.id = id
        self.image_url = URL(string: image_url)
        self.isFavourite = isFavourite
        self.favouriteId = favouriteId
        self.repository = repository
    }

    func changeFavourite() {
        let id = isFavourite ? favouriteId : self.id
        isFavourite.toggle()
        requestManager.changeFavourite(image_id: id, isFavourite: isFavourite) { [weak self] in
            self?.repository?.loadFavourites()
        }
    }
}
