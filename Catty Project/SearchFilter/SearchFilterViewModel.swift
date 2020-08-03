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
    let categories = BehaviorSubject<[CatCategory]>(value: [])

    let selectedSort = PublishSubject<String>()
    let gifIsOn = PublishSubject<Bool>()
    let selectedCategory = PublishSubject<CatCategory>()
    let onApplySettings = PublishSubject<Void>()
    let onSettingsChanged = PublishSubject<Bool>()

    private(set) var sorting = User.shared.sorting
    private(set) var onlyGif = User.shared.onlyGif
    private(set) var categoryId = User.shared.categoryId

    init() {
        setupBindings()
    }

    private let disposeBag = DisposeBag()

    private func setupBindings() {
        let requestManager = RequestManager()
        requestManager.getCategoriesList().subscribe(onSuccess: { [weak self] in
            self?.categories.onNext($0)
        }).disposed(by: disposeBag)

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
            guard let sSelf = self else { return }
            if User.shared.sorting != sSelf.sorting ||
                User.shared.onlyGif != sSelf.onlyGif || User.shared.categoryId != sSelf.categoryId {
                
                User.shared .sorting = sSelf.sorting
                User.shared.onlyGif = sSelf.onlyGif
                User.shared.categoryId = sSelf.categoryId
                sSelf.onSettingsChanged.onNext(true)
            } else { sSelf.onSettingsChanged.onNext(false) }

        }).disposed(by: disposeBag)
    }
}
