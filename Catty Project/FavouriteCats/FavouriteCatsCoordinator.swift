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
    
    let viewController = FavouriteCatsController()
    
    override func start() -> Observable<CoordinationResult> {
        return .never()
    }
    
}
