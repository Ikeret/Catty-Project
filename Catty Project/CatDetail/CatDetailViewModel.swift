//
//  CatDetailViewModel.swift
//  Catty Project
//
//  Created by Сергей Коршунов on 17.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import Foundation
import RxSwift

final class CatDetailViewModel {

    let title = "Cat Info"

    let image_id: String
    let image_url: URL?
    private(set) var vote: Vote?

    let onDetailLoaded = PublishSubject<Void>()
    let onVoteLoaded = PublishSubject<Void>()

    private(set) var detailInfo = [[(name: String, value: String)]]()
    private(set) var detailStats = [[(name: String, value: Int)]]()
    private(set) var detailLinks = [[(key: String, value: String)]]()

    init(image_id: String, image_url: URL?) {
        self.image_id = image_id
        self.image_url = image_url

        DispatchQueue.global().async {
            self.prepareData()
        }

        loadVote()
    }

    func changeVote(newValue: Int) {
        DataProvider.shared.vote(image_id: image_id, value: newValue)
    }

    private let disposeBag = DisposeBag()

    private func prepareData() {
        DataProvider.shared.loadImage(image_id: image_id).subscribe(onNext: { [weak self] catDetail in
            debugPrint(catDetail)
            if let breeds = catDetail.breeds {
                for breed in breeds {
                    var breedInfo = [(name: String, value: String)]()

                    breedInfo.append((name: "Breed name", value: breed.name))
                    breedInfo.append((name: "Temperament", value: breed.temperament))
                    breedInfo.append((name: "Life span", value: breed.life_span))
                    if let alt_names = breed.alt_names, !alt_names.isEmpty {
                        breedInfo.append((name: "Alternative names", value: alt_names))
                    }

                    breedInfo.append((name: "Origin", value: breed.origin))
                    breedInfo.append((name: "Weight, lb", value: breed.weight.imperial))
                    breedInfo.append((name: "Weight, kg", value: breed.weight.metric))

                    var characteristics = [String]()
                    if breed.experimental == 1 { characteristics.append("experimental") }
                    if breed.hairless == 1 { characteristics.append("hairless") }
                    if breed.natural == 1 { characteristics.append("natural") }
                    if breed.rare == 1 { characteristics.append("rare") }
                    if breed.rex == 1 { characteristics.append("rex") }
                    if breed.suppressed_tail == 1 { characteristics.append("suppressed tail") }
                    if breed.short_legs == 1 { characteristics.append("short legs") }
                    if breed.hypoallergenic == 1 { characteristics.append("hypoallergenic") }

                    if !characteristics.isEmpty {
                        breedInfo.append((name: "Description", value: characteristics.joined(separator: ", ")))
                    }

                    self?.detailInfo.append(breedInfo)

                    var stats = [(name: String, value: Int)]()

                    stats.append((name: "Adaptability", value: breed.adaptability))
                    stats.append((name: "Affection level", value: breed.affection_level))
                    stats.append((name: "Child friendly", value: breed.child_friendly))
                    stats.append((name: "Dog friendly", value: breed.dog_friendly))
                    stats.append((name: "Energy level", value: breed.energy_level))
                    stats.append((name: "Grooming", value: breed.grooming))
                    stats.append((name: "Health issues", value: breed.health_issues))
                    stats.append((name: "Intelligence", value: breed.intelligence))
                    stats.append((name: "Shedding level", value: breed.shedding_level))
                    stats.append((name: "Social needs", value: breed.social_needs))
                    stats.append((name: "Stranger friendly", value: breed.stranger_friendly))
                    stats.append((name: "Vocalisation", value: breed.vocalisation))

                    self?.detailStats.append(stats)

                    var links = [String: String]()
                    links["cfa.org"] = breed.cfa_url
                    links["vetstreet.com"] = breed.vetstreet_url
                    links["wikipedia.org"] = breed.wikipedia_url
                    links["vcahospitals.com"] = breed.vcahospitals_url

                    self?.detailLinks.append(links.sorted {$0.key < $1.key})
                }
            }

            self?.onDetailLoaded.onCompleted()
        }).disposed(by: disposeBag)
    }

    private func loadVote() {
        DataProvider.shared.loadVote(image_id: image_id).subscribe(onNext: { [weak self] vote in
            self?.vote = vote
            self?.onVoteLoaded.onCompleted()
        }).disposed(by: disposeBag)
    }
}
