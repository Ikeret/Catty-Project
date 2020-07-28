//
//  UINavigationBar.swift
//  Catty Project
//
//  Created by Сергей Коршунов on 28.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import UIKit

extension UINavigationBar {
    func setupTranslusent() {
        self.setBackgroundImage(UIImage(), for: .default)
        self.shadowImage = UIImage()
        self.isTranslucent = true
    }
    
    func setupNormal() {
        self.setBackgroundImage(nil, for: .default)
        self.shadowImage = nil
        self.isTranslucent = false
    }
}
