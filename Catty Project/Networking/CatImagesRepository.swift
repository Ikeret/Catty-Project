//
//  CatImagesRepository.swift
//  Catty Project
//
//  Created by Сергей Коршунов on 16.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import Foundation
import Moya
import Kingfisher
import RxSwift

final class CatImagesRepository {
    private let provider = MoyaProvider<CatAPI>()

    let catImages = BehaviorSubject<[CatCellViewModel]>(value: [])
    let favImages = BehaviorSubject<[FavouriteImage]>(value: [])
    
    private let disposeBag = DisposeBag()


    func loadCatImages(page: Int = 0) {

        provider.rx.request(.getImagesFromPage(page))
            .map([CatImage].self)
            .subscribe(onSuccess: { [weak self] catImages in
                // prefetch images
                let urls = catImages.compactMap {URL(string: $0.url)}
                    .filter { !$0.absoluteString.hasSuffix(".gif") }

                ImagePrefetcher(urls: urls, options: [.cacheOriginalImage, .originalCache(.default)]).start()

                // get pair image_id + favourite_id
                let favImages = (try? self?.favImages.value()) ?? []
                var favIds = [String: String]()

                for id in favImages.map({ ($0.image.id, $0.id) }) {
                    favIds[id.0] = "\(id.1)"
                }

                // create new data
                let newData = catImages.map {
                    CatCellViewModel(id: $0.id,
                                     image_url: $0.url,
                                     favouriteId: favIds[$0.id] ?? "",
                                     repository: self,
                                     isFavourite: favIds.keys.contains($0.id))
                }
                self?.catImages.onNext(newData)
            }).disposed(by: disposeBag)
    }

    func loadFavourites() {
        provider.rx.request(.getFavourites)
            .map([FavouriteImage].self)
            .subscribe(onSuccess: { [weak self] newData in
                self?.favImages.onNext(newData)
            }).disposed(by: disposeBag)
    }
}
