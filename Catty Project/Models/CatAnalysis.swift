//
//  CatAnalysis.swift
//  Catty Project
//
//  Created by Сергей Коршунов on 24.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import Foundation

struct CatAnalysis: Decodable {
    let labels: [Label]
}

struct Label: Decodable {
    let Name: String
    let Confidence: Double
}
