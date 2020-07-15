//
//  Breed.swift
//  Catty Project
//
//  Created by Сергей Коршунов on 15.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import Foundation

struct Breed: Decodable {
    let adaptability, affectionLevel: Int
    let altNames: String?
    let cfaURL: String?
    let childFriendly: Int
    let countryCode, countryCodes, countryDescription: String
    let dogFriendly, energyLevel, experimental, grooming: Int
    let hairless, healthIssues, hypoallergenic: Int
    let id: String
    let indoor, intelligence: Int
    let lap: Int?
    let lifeSpan, name: String
    let natural: Int
    let origin: String
    let rare, rex, sheddingLevel, shortLegs: Int
    let socialNeeds, strangerFriendly, suppressedTail: Int
    let temperament: String
    let vcahospitalsURL: String?
    let vetstreetURL: String?
    let vocalisation: Int
    let weight: Weight
    let wikipediaURL: String?
    let bidability, catFriendly: Int?
}

struct Weight: Decodable {
    let imperial, metric: String
}
