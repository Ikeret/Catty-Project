//
//  RequestManager.swift
//  Catty Project
//
//  Created by Сергей Коршунов on 03.08.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import Foundation
import Moya
import RxSwift

final class RequestManager {
    
    private let provider = MoyaProvider<CatAPI>()
    
    private let disposeBag = DisposeBag()
    
    func changeFavourite(image_id: String, isFavourite: Bool, completion: @escaping () -> Void) {
        if isFavourite {
            provider.rx.request(.markImageAsFavourite(image_id))
                .mapJSON().subscribe(onSuccess: {
                    debugPrint($0)
                    completion()
                }, onError: { error in debugPrint(error.localizedDescription) })
                .disposed(by: disposeBag)
        } else {
            provider.rx.request(.deleteImageFromFavourite(image_id))
                .mapJSON().subscribe(onSuccess: {
                    debugPrint($0)
                    completion()
                }, onError: { error in debugPrint(error.localizedDescription) })
                .disposed(by: disposeBag)
        }

    }

    
    func loadImage(image_id: String) -> Single<CatDetail> {
        return Single.create { [weak self] single in
            let request = self?.provider.rx.request(.getImage(image_id))
                .map(CatDetail.self, failsOnEmptyData: false)
                .subscribe(onSuccess: { catImage in
                    single(.success(catImage))
                })
            return Disposables.create {
                request?.dispose()
            }
        }
    }

    func loadVote(image_id: String) -> Single<Vote?> {
        return Single.create { [weak self] single in
            let request = self?.provider.rx.request(.getVotes)
                .map([Vote].self, failsOnEmptyData: false)
                .subscribe(onSuccess: { votes in
                    single(.success(votes.first(where: { $0.image_id == image_id })))
                })
            return Disposables.create {
                request?.dispose()
            }
        }
    }

    func vote(image_id: String, value: Int) {
        provider.rx.request(.vote(image_id, value))
            .mapJSON().subscribe(onSuccess: { debugPrint($0)})
            .disposed(by: disposeBag)
    }

    func getCategoriesList() -> Single<[CatCategory]> {
        return Single.create { [weak self] single in
            let request = self?.provider.rx.request(.getCategoriesList)
                .map([CatCategory].self).subscribe(onSuccess: {
                    var categories = $0
                    categories.insert(CatCategory(id: 0, name: "All"), at: 0)
                    single(.success(categories))
                })
            return Disposables.create {
                request?.dispose()
            }
        }
    }
    
    func getImageAnalysis(image_id: String) -> Single<CatAnalysis> {
        Single<CatAnalysis>.create { [weak self] single in
            let request = self?.provider.rx.request(.getImageAnalysis(image_id)).map([CatAnalysis].self)
                .subscribe(onSuccess: { model in
                    single(.success(model.first ?? CatAnalysis(labels: [])))
                }, onError: { single(.error($0)) })
            
            return Disposables.create { request?.dispose() }
        }
    }
}
