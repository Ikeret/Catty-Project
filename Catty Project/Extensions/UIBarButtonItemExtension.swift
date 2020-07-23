//
//  UIBarButtonItemExtension.swift
//  Catty Project
//
//  Created by Сергей Коршунов on 22.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    class func backButton() -> UIBarButtonItem {
        return UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
    }
}
