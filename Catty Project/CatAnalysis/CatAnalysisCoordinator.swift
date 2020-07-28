//
//  CatAnalysisCoordinator.swift
//  Catty Project
//
//  Created by Сергей Коршунов on 24.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import UIKit
import RxSwift

final class CatAnalysisCoordinator: BaseCoordinator<CoordinationResult> {
    
    let viewModel: CatAnalysisViewModel
    let viewController: CatAnalysisController
    
    private let result = PublishSubject<CoordinationResult>()
    
    init(viewModel: CatAnalysisViewModel, navigationController: UINavigationController? = nil) {
        self.viewModel = viewModel
        viewController = CatAnalysisController(viewModel: viewModel)
        
        super.init(navigationController: navigationController)
        navigationController?.delegate = self
    }
    
    override func start() -> Observable<CoordinationResult> {
        viewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewController, animated: true)
        
        return result.take(1)
    }
    
}

extension CatAnalysisCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController != self.viewController {
            result.onNext(.backSwipe)
        }
    }
    
}
