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
    
    let viewModel = CatImagesViewModel()
    let viewController: CatImagesController
    
    override init() {
        viewController = CatImagesController(viewModel)
    }
    
    override func start() -> Observable<CoordinationResult> {
        
        viewModel.onFilterButtonTapped.subscribe(onNext: { [weak self] in
            self?.showFilter()
            }).disposed(by: bag)
        
        
        return .never()
    }
    
    private func showFilter() {
        let coordinator = SearchFilterCoordinator()
        coordinate(to: coordinator).subscribe(onNext: { [weak self] in
            switch $0 {
            case .success(let settingsChanged):
                if settingsChanged { self?.viewModel.onReloadData.onNext(()) }
            default:
                return
            }
        }).disposed(by: bag)
    }
    
}
