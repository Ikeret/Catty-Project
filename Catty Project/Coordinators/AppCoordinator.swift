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
        
        let tabBarController = UITabBarController()
        
        let catImagesVC = CatImagesController(viewModel: CatImagesViewModel())
        let catImagesNC = UINavigationController(rootViewController: catImagesVC)
        catImagesNC.tabBarItem = .init(title: "Home", image: UIImage(systemName: "house.fill"), tag: 0)
        
        let favCatsVC = FavouriteCatsController(viewModel: FavouriteCatsViewModel())
        let favCatsNC = UINavigationController(rootViewController: favCatsVC)
        favCatsNC.tabBarItem = .init(title: "Likes", image: UIImage(systemName: "heart.fill"), tag: 1)
        
        tabBarController.setViewControllers([catImagesNC, favCatsNC], animated: false)
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        
    }
    
    
    override func start() -> Observable<Void> {
        return Observable.never()
    }
}

