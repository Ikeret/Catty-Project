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
    
    override init(navigationController: UINavigationController? = nil) {
        viewController = SearchFilterController(viewModel)
        super.init(navigationController: navigationController)
    }
    
    override func start() -> Observable<CoordinationResult> {
        viewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewController, animated: true)
        
        
        let result = PublishSubject<CoordinationResult>()
        viewModel.onSettingsChanged.subscribe(onNext: {
            result.onNext(.success($0))
        }).disposed(by: bag)
        
        viewModel.onApplySettings.subscribe(onNext: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: bag)
        
        return result
    }
    
}
