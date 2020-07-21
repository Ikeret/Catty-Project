//
//  Vote.swift
//  Catty Project
//
//  Created by Сергей Коршунов on 20.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import Foundation

struct Vote: Decodable {
    let id: Int
    let image_id: String
    let value: Int
}
