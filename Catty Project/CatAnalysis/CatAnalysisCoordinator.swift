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
    
    init(viewModel: CatAnalysisViewModel, navigationController: UINavigationController? = nil) {
        self.viewModel = viewModel
        viewController = CatAnalysisController(viewModel: viewModel)
        
        super.init(navigationController: navigationController)
    }
    
    override func start() -> Observable<CoordinationResult> {
        viewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewController, animated: true)
        
        return .never()
    }
    
}
