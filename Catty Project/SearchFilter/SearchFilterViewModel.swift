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
    let categories = PublishSubject<[Category]>()
    
    let selectedCategory = PublishSubject<String>()
    
    struct DisplayItem {
        let name: String
        let isSelected: Bool
    }
    
    init() {
        DataProvider.shared.getCategoriesList().subscribe(onNext: { [weak self] categories in
            
            self?.categories.onNext(categories)
        }).disposed(by: disposeBag)
    }
    
    let disposeBag = DisposeBag()
}
