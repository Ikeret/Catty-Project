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
    private let result = PublishSubject<CoordinationResult>()
    
    override init(navigationController: UINavigationController? = nil) {
        viewController = SearchFilterController(viewModel)
        super.init(navigationController: navigationController)
        navigationController?.delegate = self
    }
    
    override func start() -> Observable<CoordinationResult> {
        viewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewController, animated: true)
        
        viewModel.onSettingsChanged.subscribe(onNext: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
            self?.result.onNext(.success($0))
        }).disposed(by: bag)

        return result.take(1)
    }
    
}

extension SearchFilterCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController != self.viewController {
            result.onNext(.backSwipe)
        }
    }
    
}
