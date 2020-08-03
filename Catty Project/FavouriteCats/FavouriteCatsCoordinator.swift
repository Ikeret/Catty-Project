//
//  FavouriteCatsCoordinator.swift
//  Catty Project
//
//  Created by Сергей Коршунов on 24.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import UIKit
import RxSwift

final class FavouriteCatsCoordinator: BaseCoordinator<CoordinationResult> {
    
    let viewModel: FavouriteCatsViewModel
    let viewController: FavouriteCatsController
    
    init(repository: CatImagesRepository, navigationController: UINavigationController? = nil) {
        viewModel = FavouriteCatsViewModel(repository: repository)
        viewController = FavouriteCatsController(viewModel)
        super.init(navigationController: navigationController)
    }
    
    override func start() -> Observable<CoordinationResult> {
        
        viewModel.modelSelected.subscribe(onNext: { [weak self] in self?.showDetail(viewModel: $0) })
            .disposed(by: bag)
        
        return .never()
    }
    
    private func showDetail(viewModel: CatDetailViewModel) {
        let coordinator = CatDetailCoordinator(viewModel: viewModel,
                                               navigationController: navigationController)
        coordinate(to: coordinator).subscribe().disposed(by: bag)
    }
    
}
