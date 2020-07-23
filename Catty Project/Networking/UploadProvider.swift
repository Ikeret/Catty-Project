//
//  UploadProvider.swift
//  Catty Project
//
//  Created by Сергей Коршунов on 22.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import Foundation
import Moya
import Kingfisher
import RxSwift

final class UploadProvider {
    static let shared = UploadProvider()

    private let provider = MoyaProvider<CatAPI>()

    let catImages = PublishSubject<[CatCellViewModel]>()

    struct UploadResponse: Decodable {
        let url: String?
        let message: String?
    }

    func loadUploadedImages(page: Int = 0) {
        provider.rx.request(.getUploadedImages(page)).map([CatImage].self)
            .subscribe(onSuccess: { [weak self] response in
                let viewModels = response.map {
                    CatCellViewModel(id: $0.id,
                                     image_url: $0.url,
                                     width: $0.width,
                                     height: $0.height,
                                     favouriteId: "")
                }
                self?.catImages.onNext(viewModels)
            }).disposed(by: disposeBag)
    }

    func sendFile(_ fileURL: URL) -> Maybe<String> {
        debugPrint("Sending file...")
        return Maybe<String>.create { [weak self] maybe in

            let request = self?.provider.rx.request(.uploadImageFromURL(fileURL))
                .map(UploadResponse.self).subscribe(onSuccess: { response in
                    if let url = response.url {
                        maybe(.success(url))
                    } else if let message = response.message {
                        maybe(.success(message))
                    } else {
                        maybe(.completed)
                    }
                }, onError: { error in
                    maybe(.error(error))
                })

            return Disposables.create { request?.dispose() }
        }

    }

    func sendFile(_ data: Data) -> Maybe<String> {
        let fileName = UUID().uuidString
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName + ".jpeg")
        FileManager.default.createFile(atPath: url.path, contents: data)

        return sendFile(url)
    }

    let disposeBag = DisposeBag()
}
