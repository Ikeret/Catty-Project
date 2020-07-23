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
    let size: CGSize
    var favouriteId: String

    var favImageName: String {
        isFavourite ? "heart.fill" : "heart"
    }

    let onChangeFavourite = PublishSubject<Void>()

    init(id: String, image_url: String, width: Int?, height: Int?, favouriteId: String, isFavourite: Bool = false) {
        self.id = id
        self.image_url = URL(string: image_url)
        self.size = CGSize(width: width ?? 0, height: height ?? 0)
        self.isFavourite = isFavourite
        self.favouriteId = favouriteId
        onChangeFavourite.subscribe(onNext: { [weak self] in
            guard let strongSelf = self else { return }

            let id = strongSelf.isFavourite ? strongSelf.favouriteId : strongSelf.id
            strongSelf.isFavourite.toggle()
            DataProvider.shared.changeFavourite(image_id: id, isFavourite: strongSelf.isFavourite)
            }).disposed(by: disposeBag)
    }
    let disposeBag = DisposeBag()
}
