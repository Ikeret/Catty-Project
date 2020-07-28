//
//  AppCoordinator.swift
//  Catty Project
//
//  Created by Сергей Коршунов on 15.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import UIKit
import RxSwift

final class AppCoordinator: BaseCoordinator<Void> {
    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
        window.makeKeyAndVisible()
    }

    override func start() -> Observable<Void> {
        if User.registerLastUser() {
            showContent()
        } else {
            showLogin()
        }
        return .never()
    }
    
    func showLogin() {
        coordinate(to: LoginCoordinator(window: window)).map { _ in}
            .subscribe(onNext: showContent).disposed(by: bag)
    }
    
    func showContent() {
        coordinate(to: TabBarCoordinator(window: window)).map { _ in}
            .subscribe(onNext: showLogin).disposed(by: bag)
    }
}
