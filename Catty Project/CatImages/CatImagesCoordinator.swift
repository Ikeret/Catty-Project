//
//  CatImagesCoordinator.swift
//  Catty Project
//
//  Created by Сергей Коршунов on 24.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import UIKit
import RxSwift

final class CatImagesCoordinator: BaseCoordinator<CoordinationResult> {
    
    let viewModel: CatImagesViewModel
    let viewController: CatImagesController
    
    init(repository: CatImagesRepository, navigationController: UINavigationController? = nil) {
        viewModel = CatImagesViewModel(repository: repository)
        viewController = CatImagesController(viewModel)
        super.init(navigationController: navigationController)
    }
    
    override func start() -> Observable<CoordinationResult> {
        let result = PublishSubject<CoordinationResult>()
        
        viewModel.onFilterButtonTapped.subscribe(onNext: { [weak self] in self?.showFilter() })
            .disposed(by: bag)
        viewModel.modelSelected.subscribe(onNext: { [weak self] in self?.showDetail(viewModel: $0) })
            .disposed(by: bag)
        
        viewModel.onLogOutButtonTapped.subscribe(onNext: {
            result.onNext(.logOut)
        }).disposed(by: bag)
        
        return result
    }
    
    private func showFilter() {
        let coordinator = SearchFilterCoordinator(navigationController: navigationController)
        coordinate(to: coordinator).subscribe(onNext: { [weak self] in
            switch $0 {
            case .success(let settingsChanged):
                if settingsChanged { self?.viewModel.onReloadData.onNext(()) }
            default:
                return
            }
        }).disposed(by: bag)
    }
    
    private func showDetail(viewModel: CatDetailViewModel) {
        let coordinator = CatDetailCoordinator(viewModel: viewModel,
                                               navigationController: navigationController)
        coordinate(to: coordinator).subscribe().disposed(by: bag)
    }
    
}


