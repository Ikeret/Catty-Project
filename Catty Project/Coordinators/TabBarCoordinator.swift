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
        
        let catImagesVC = catImagesCoordinator.viewController
        let catImagesNC = UINavigationController(rootViewController: catImagesVC)
        catImagesNC.tabBarItem = .init(title: "Home", image: UIImage(systemName: "house.fill"), tag: 0)
        catImagesCoordinator.navigationController = catImagesNC
        catImagesCoordinator.start().subscribe().disposed(by: bag)
        
        let favCatsVC = favouriteCatsCoordinator.viewController
        let favCatsNC = UINavigationController(rootViewController: favCatsVC)
        favCatsNC.tabBarItem = .init(title: "Likes", image: UIImage(systemName: "heart.fill"), tag: 1)
        favouriteCatsCoordinator.navigationController = favCatsNC
        favouriteCatsCoordinator.start().subscribe().disposed(by: bag)
        
        let myUploadsVC = myUploadsCoordinator.viewController
        let myUploadsNC = UINavigationController(rootViewController: myUploadsVC)
        myUploadsNC.tabBarItem = .init(title: "Uploads", image: UIImage(systemName: "icloud.and.arrow.up.fill"), tag: 2)
        myUploadsCoordinator.navigationController = myUploadsNC
        myUploadsCoordinator.start().subscribe().disposed(by: bag)
        
        
        tabBarController.viewControllers = [catImagesNC, favCatsNC, myUploadsNC]
        
        window.rootViewController = tabBarController
        
        return .never()
    }
}
