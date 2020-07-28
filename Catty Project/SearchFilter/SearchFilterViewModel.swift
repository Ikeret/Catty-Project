//
//  SearchFilterViewModel.swift
//  Catty Project
//
//  Created by Сергей Коршунов on 20.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import Foundation
import RxSwift

final class SearchFilterViewModel {
    let title = "Search filter"
    let categories = BehaviorSubject<[Category]>(value: [])

    let selectedSort = PublishSubject<String>()
    let gifIsOn = PublishSubject<Bool>()
    let selectedCategory = PublishSubject<Category>()
    let onApplySettings = PublishSubject<Void>()
    let onSettingsChanged = PublishSubject<Bool>()

    private(set) var sorting = User.sorting
    private(set) var onlyGif = User.onlyGif
    private(set) var categoryId = User.categoryId

    init() {
        setupBindings()
    }

    let disposeBag = DisposeBag()

    private func setupBindings() {
        DataProvider.shared.getCategoriesList().bind(to: categories).disposed(by: disposeBag)

        selectedSort.subscribe(onNext: { [weak self] in
            self?.sorting = $0
        }).disposed(by: disposeBag)

        gifIsOn.subscribe(onNext: { [weak self] in
            self?.onlyGif = $0
        }).disposed(by: disposeBag)

        selectedCategory.subscribe(onNext: { [weak self] in
            self?.categoryId = $0.id
        }).disposed(by: disposeBag)

        onApplySettings.subscribe(onNext: { [weak self] in
            guard let strongSelf = self else { return }
            if User.sorting != strongSelf.sorting || User.onlyGif != strongSelf.onlyGif ||
                User.categoryId != strongSelf.categoryId {
                User.sorting = strongSelf.sorting
                User.onlyGif = strongSelf.onlyGif
                User.categoryId = strongSelf.categoryId
                strongSelf.onSettingsChanged.onNext(true)
            } else { strongSelf.onSettingsChanged.onNext(false) }

        }).disposed(by: disposeBag)
    }
}