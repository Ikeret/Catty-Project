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
    
    let dataProvider = DataProvider.shared
    
    let onLoadNextPage = PublishSubject<Void>()
    
    let displayItems = BehaviorSubject(value: [CatCellViewModel]())
    private(set) var storedItems = [CatCellViewModel]()
    private(set) var isLoading = false
    private var page = 1
    
    
    init() {
        loadNextPage()
        
        onLoadNextPage.subscribe(onNext: { [weak self] in
            self?.loadNextPage()
            }).disposed(by: disposeBag)
        
        dataProvider.favImages.subscribe(onNext: { [weak self, page] images in
            let mapped = images.map { CatCellViewModel(id: $0.image.id, image_url: $0.image.url, width: $0.image.width, height: $0.image.height, favouriteId: "\($0.id)", isFavourite: true) }
            self?.storedItems = mapped
            self?.displayItems.onNext(Array(mapped.prefix(50*page)))
        }).disposed(by: disposeBag)
    }
    
    func loadNextPage() {
        displayItems.onNext(Array(storedItems.prefix(50*page)))
        page += 1
    }
    
    private let disposeBag = DisposeBag()
}
