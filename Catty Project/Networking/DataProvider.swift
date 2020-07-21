//
//  DataProvider.swift
//  Catty Project
//
//  Created by Сергей Коршунов on 16.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import Foundation
import Moya
import Kingfisher
import RxSwift

final class DataProvider {
    static let shared = DataProvider()
    
    private let provider = MoyaProvider<CatAPI>()
    
    let catImages = BehaviorSubject<[CatCellViewModel]>(value: [])
    let favImages = BehaviorSubject<[FavouriteImage]>(value: [])
    
    init() {
        loadFavourites()
    }
    
    func loadCatImages(page: Int = 0, category: Int = 0) {
        
        provider.rx.request(.getImagesFromPage(page, category, "ASC"))
            .map([CatImage].self)
            .subscribe(onSuccess: { [weak self] catImages in
                // prefetch images
                let urls = catImages.compactMap {URL(string: $0.url)}
                ImagePrefetcher(urls: urls).start()
                
                // get pair image_id + favourite_id
                let favImages = (try? self?.favImages.value()) ?? []
                var favIds = [String: String]()
                
                for id in favImages.map({ ($0.image.id, $0.id) }) {
                    favIds[id.0] = "\(id.1)"
                }
                
                // create new data
                let newData = catImages.map { CatCellViewModel(id: $0.id, image_url: $0.url, width: $0.width, height:  $0.height, favouriteId: favIds[$0.id] ?? "", isFavourite: favIds.keys.contains($0.id)) }
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
    
    
    
    func changeFavourite(image_id: String, isFavourite: Bool) {
        if isFavourite {
            provider.rx.request(.markImageAsFavourite(image_id))
                .mapJSON().subscribe(onSuccess: { [weak self] in
                    debugPrint($0)
                    self?.loadFavourites()
                }) { error in debugPrint(error.localizedDescription) }
                .disposed(by: disposeBag)
        } else {
            provider.rx.request(.deleteImageFromFavourite(image_id))
                .mapJSON().subscribe(onSuccess: { [weak self] in
                    debugPrint($0)
                    self?.loadFavourites()
                }) { error in debugPrint(error.localizedDescription) }
                .disposed(by: disposeBag)
        }
        
    }
    
    
    func loadImage(image_id: String) -> Observable<CatDetail> {
        return Observable.create { [provider] observer in
            provider.rx.request(.getImage(image_id))
                .map(CatDetail.self, failsOnEmptyData: false)
                .subscribe(onSuccess: { catImage in
                    observer.onNext(catImage)
                    observer.onCompleted()
                }, onError: { observer.onError($0) })
            
        }
    }
    
    func loadVote(image_id: String) -> Observable<Vote?> {
        return Observable.create { [provider] observer in
            provider.rx.request(.getVotes)
                .map([Vote].self, failsOnEmptyData: false)
                .subscribe(onSuccess: { votes in
                    observer.onNext(votes.first(where: { $0.image_id == image_id }))
                    observer.onCompleted()
                })
        }
    }
    
    func vote(image_id: String, value: Int) {
        provider.rx.request(.vote(image_id, value))
            .mapJSON().subscribe(onSuccess: { debugPrint($0)})
            .disposed(by: disposeBag)
    }
    
    func deleteVote(vote_id: Int) {
        provider.rx.request(.deleteVote(vote_id))
            .mapJSON().subscribe(onSuccess: { debugPrint($0)})
            .disposed(by: disposeBag)
    }
    
    func getCategoriesList() -> Observable<[Category]> {
        return Observable.create { [provider] observer in
            provider.rx.request(.getCategoriesList)
                .map([Category].self).subscribe(onSuccess: {
                    observer.onNext($0)
                })
        }
    }
    
    private let disposeBag = DisposeBag()
}

