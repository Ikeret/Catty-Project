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

    private let provider = MoyaProvider<CatAPI>()

    let catImages = PublishSubject<[CatCellViewModel]>()
    
    let disposeBag = DisposeBag()

    struct UploadResponse: Decodable {
        let url: String?
        let message: String?
    }

    func loadUploadedImages(page: Int = 0) {
        provider.rx.request(.getUploadedImages(page)).map([CatImage].self)
            .subscribe(onSuccess: { [weak self] response in
                let viewModels = response.map {
                    CatCellViewModel(id: $0.id, image_url: $0.url, favouriteId: "")
                }
                self?.catImages.onNext(viewModels)
            }).disposed(by: disposeBag)
    }

    private func sendFile(_ fileURL: URL) -> Maybe<String> {
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

    func sendData(_ data: Data) -> Maybe<String> {
        let fileName = UUID().uuidString
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName + ".jpeg")
        FileManager.default.createFile(atPath: url.path, contents: data)

        return sendFile(url)
    }

    func deleteImage(image_id: String) {
        provider.rx.request(.deleteUploadedImage(image_id)).mapJSON(failsOnEmptyData: false)
            .subscribe(onSuccess: { debugPrint($0) }).disposed(by: disposeBag)
    }
}
