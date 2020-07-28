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
    
    override func start() -> Observable<CoordinationResult> {
        return .never()
    }
    
}