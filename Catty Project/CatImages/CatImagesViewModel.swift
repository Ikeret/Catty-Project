//
//  CatImagesViewModel.swift
//  Catty Project
//
//  Created by Сергей Коршунов on 16.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import Foundation
import RxSwift

final class CatImagesViewModel {
    
    private let dataProvider = DataProvider.shared
    
    let title = "Cat Images"
    
    let onLoadNextPage = PublishSubject<Void>()
    
    
    let displayItems = BehaviorSubject(value: [CatCellViewModel]())
    private(set) var storedItems = [CatCellViewModel]()
    private(set) var isLoading = false
    private var page = 0
    
    init() {
        loadNextPage()
        
        onLoadNextPage.subscribe(onNext: { [weak self] in
            self?.loadNextPage()
            }).disposed(by: disposeBag)
        
        dataProvider.catImages.subscribe(onNext: { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.storedItems.append(contentsOf: $0)
        
            strongSelf.displayItems.onNext(strongSelf.storedItems)
            strongSelf.isLoading = false
            strongSelf.page += 1

        }).disposed(by: disposeBag)
        
        dataProvider.favImages.subscribe(onNext: { [weak self] favImages in
            guard let strongSelf = self else { return }
            var favIds = [String: String]()
            for id in favImages.map({ ($0.image.id, $0.id) }) {
                favIds[id.0] = "\(id.1)"
            }
            strongSelf.storedItems.forEach { $0.favouriteId = favIds[$0.id] ?? ""; $0.isFavourite = favIds.keys.contains($0.id) }
            strongSelf.displayItems.onNext(strongSelf.storedItems)
        }).disposed(by: disposeBag)
    }
    
    func loadNextPage() {
        isLoading = true
        dataProvider.loadCatImages(page: page)
    }
    
    let disposeBag = DisposeBag()
}
