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

    private let repository: CatImagesRepository

    let title = "Cat Images"

    let onReloadData = PublishSubject<Void>()
    let onLogOutButtonTapped = PublishSubject<Void>()
    let onFilterButtonTapped = PublishSubject<Void>()
    let modelSelected = PublishSubject<CatDetailViewModel>()

    let displayItems = BehaviorSubject(value: [CatCellViewModel]())
    private(set) var storedItems = [CatCellViewModel]()
    private(set) var isLoading = false
    private var page = 0

    init(repository: CatImagesRepository = CatImagesRepository()) {
        self.repository = repository
        loadNextPage()
        setupBindings()
    }

    func loadNextPage() {
        isLoading = true
        repository.loadCatImages(page: page)
    }

    private let disposeBag = DisposeBag()

    private func setupBindings() {
        repository.catImages.subscribe(onNext: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.storedItems.append(contentsOf: $0)

            strongSelf.displayItems.onNext(strongSelf.storedItems)
            strongSelf.isLoading = false
            strongSelf.page += 1

        }).disposed(by: disposeBag)

        repository.favImages.subscribe(onNext: { [weak self] favImages in
            guard let strongSelf = self else { return }
            var favIds = [String: String]()
            for id in favImages.map({ ($0.image.id, $0.id) }) {
                favIds[id.0] = "\(id.1)"
            }
            strongSelf.storedItems.forEach {
                $0.favouriteId = favIds[$0.id] ?? ""
                $0.isFavourite = favIds.keys.contains($0.id)
            }
            strongSelf.displayItems.onNext(strongSelf.storedItems)
        }).disposed(by: disposeBag)

        onReloadData.subscribe(onNext: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.page = 0
            strongSelf.storedItems = []
            strongSelf.loadNextPage()
        }).disposed(by: disposeBag)
    }
}
