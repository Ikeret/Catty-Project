//
//  LoginCoordinator.swift
//  Catty Project
//
//  Created by Сергей Коршунов on 16.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import UIKit
import RxSwift

final class LoginCoordinator: BaseCoordinator<CoordinationResult> {
    private let window: UIWindow
    
    private let viewModel = LoginViewModel()
    private let viewController: LoginController
    
    init(window: UIWindow) {
        viewController = LoginController(viewModel)
        self.window = window
    }
    
    override func start() -> Observable<CoordinationResult> {
        let result = PublishSubject<CoordinationResult>()
        
        viewModel.registerUser.subscribe(onNext: { _ in
            result.onNext(.logIn)
        }).disposed(by: bag)
        
        window.rootViewController = viewController
        
        return result.take(1)
    }
    
}
