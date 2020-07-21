//
//  CatDetail.swift
//  Catty Project
//
//  Created by Сергей Коршунов on 19.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import Foundation

// MARK: - CatDetail
struct CatDetail: Decodable {
    let breeds: [Breed]?
    let height: Int
    let id: String
    let url: String
    let width: Int
}

// MARK: - Breed
struct Breed: Decodable {
    let adaptability, affection_level: Int
    let alt_names: String?
    let cfa_url: String?
    let child_friendly: Int
    let country_code, country_codes: String
    let cat_detail_description: String?
    let dog_friendly, energy_level, experimental, grooming: Int
    let hairless, health_issues, hypoallergenic: Int
    let id: String
    let indoor, intelligence: Int
    let lap: Int?
    let life_span, name: String
    let natural: Int
    let origin: String
    let rare, rex, shedding_level, short_legs: Int
    let social_needs, stranger_friendly, suppressed_tail: Int
    let temperament: String
    let vcahospitals_url: String?
    let vetstreet_url: String?
    let vocalisation: Int
    let weight: Weight
    let wikipedia_url: String?
    let bidability, cat_friendly: Int?
}

// MARK: - Weight
struct Weight: Decodable {
    let imperial, metric: String
}
