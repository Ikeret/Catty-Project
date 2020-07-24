//
//  SearchFilterCoordinator.swift
//  Catty Project
//
//  Created by Сергей Коршунов on 24.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import UIKit
import RxSwift

final class SearchFilterCoordinator: BaseCoordinator<CoordinationResult> {
    
    let viewModel = SearchFilterViewModel()
    let viewController: SearchFilterController
    
    override init() {
        viewController = SearchFilterController(viewModel)
    }
    
    override func start() -> Observable<CoordinationResult> {
        
        
        let result = PublishSubject<CoordinationResult>()
        
        viewModel.onSettingsChanged.subscribe(onNext: {
            result.onNext(.success($0))
        }).disposed(by: bag)
        
        
        return result
    }
    
}
