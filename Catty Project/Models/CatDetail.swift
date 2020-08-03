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
    let id: String
    let url: String
}

// MARK: - Breed
struct Breed: Decodable {
    let id: String
    
    let life_span, name: String
    let alt_names: String?
    let origin: String
    let description: String
    let weight: Weight
    let temperament: String
    let country_code: String

    // marks 0 or 1
    let experimental: Int
    let hairless: Int
    let hypoallergenic: Int
    let natural: Int
    let rare: Int
    let rex: Int
    let short_legs: Int
    let suppressed_tail: Int
    
    // stars from 1 to 5
    let adaptability: Int
    let affection_level: Int
    let child_friendly: Int
    let cat_friendly: Int?
    let dog_friendly: Int
    let energy_level: Int
    let grooming: Int
    let health_issues: Int
    let intelligence: Int
    let shedding_level: Int
    let social_needs: Int
    let stranger_friendly: Int
    let vocalisation: Int
    
    // urls
    let wikipedia_url: String?
    let vetstreet_url: String?
    let vcahospitals_url: String?
    let cfa_url: String?
}

// MARK: - Weight
struct Weight: Decodable {
    let imperial, metric: String
}
