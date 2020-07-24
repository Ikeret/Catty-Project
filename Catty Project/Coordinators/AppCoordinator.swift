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
        coordinate(to: TabBarCoordinator(window: window)).subscribe().disposed(by: bag)
        
        return Observable.never()
    }
}
