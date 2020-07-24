//
//  TabBarCoordinator.swift
//  Catty Project
//
//  Created by Сергей Коршунов on 16.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import UIKit
import RxSwift

final class TabBarCoordinator: BaseCoordinator<CoordinationResult> {
    
    private lazy var catImagesCoordinator = CatImagesCoordinator()
    private lazy var favouriteCatsCoordinator = FavouriteCatsCoordinator()
    private lazy var myUploadsCoordinator = MyUploadsCoordinator()

    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    override func start() -> Observable<CoordinationResult> {
        let tabBarController = UITabBarController()
        tabBarController.selectedIndex = 0
        
        let catImagesVC = CatImagesController()
        let catImagesNC = UINavigationController(rootViewController: catImagesVC)
        catImagesNC.tabBarItem = .init(title: "Home", image: UIImage(systemName: "house.fill"), tag: 0)

        let favCatsVC = FavouriteCatsController()
        let favCatsNC = UINavigationController(rootViewController: favCatsVC)
        favCatsNC.tabBarItem = .init(title: "Likes", image: UIImage(systemName: "heart.fill"), tag: 1)

        let myUploadsVC = MyUploadsController()
        let myUploadsNC = UINavigationController(rootViewController: myUploadsVC)
        myUploadsNC.tabBarItem = .init(title: "Uploads", image: UIImage(systemName: "icloud.and.arrow.up.fill"), tag: 2)

        tabBarController.viewControllers = [catImagesNC, favCatsNC, myUploadsNC]
        
        window.rootViewController = tabBarController
        
        return .never()
    }
}
