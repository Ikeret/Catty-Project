//
//  FavouriteCatsViewModel.swift
//  Catty Project
//
//  Created by Сергей Коршунов on 18.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import Foundation
import RxSwift

final class FavouriteCatsViewModel {
    let title = "❤️ Cats"

    private let dataProvider = DataProvider.shared

    let modelSelected = PublishSubject<CatDetailViewModel>()
    
    let displayItems = BehaviorSubject(value: [CatCellViewModel]())
    private(set) var storedItems = [CatCellViewModel]()
    private(set) var isLoading = false
    private var page = 1

    private var lastAddedFirst = true

    init() {
        dataProvider.loadFavourites()
        loadNextPage()

        dataProvider.favImages.subscribe(onNext: { [weak self] images in
            guard let strongSelf = self else { return }
            var mapped = images.map {
                CatCellViewModel(id: $0.image.id,
                                 image_url: $0.image.url,
                                 favouriteId: "\($0.id)",
                                 isFavourite: true)
            }
            if strongSelf.lastAddedFirst { mapped.reverse() }
            strongSelf.storedItems = mapped
            strongSelf.displayItems.onNext(Array(mapped.prefix(50*strongSelf.page)))
        }).disposed(by: disposeBag)

    }

    func changeSort() {
        lastAddedFirst.toggle()
        storedItems.reverse()
        displayItems.onNext(Array(storedItems.prefix(50*page)))
    }

    func loadNextPage() {
        displayItems.onNext(Array(storedItems.prefix(50*page)))
        page += 1
    }

    private let disposeBag = DisposeBag()
}
