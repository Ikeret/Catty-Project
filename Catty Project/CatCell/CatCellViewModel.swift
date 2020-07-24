//
//  CatCellViewModel.swift
//  Catty Project
//
//  Created by Сергей Коршунов on 19.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import RxSwift
import Foundation

final class CatCellViewModel {
    let id: String
    let image_url: URL?
    var isFavourite: Bool
    var favouriteId: String

    var favImageName: String {
        isFavourite ? "heart.fill" : "heart"
    }

    init(id: String, image_url: String, favouriteId: String, isFavourite: Bool = false) {
        self.id = id
        self.image_url = URL(string: image_url)
        self.isFavourite = isFavourite
        self.favouriteId = favouriteId
    }

    func changeFavourite() {
        let id = isFavourite ? favouriteId : self.id
        isFavourite.toggle()
        DataProvider.shared.changeFavourite(image_id: id, isFavourite: isFavourite)
    }
}
