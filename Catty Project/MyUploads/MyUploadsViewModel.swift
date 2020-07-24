//
//  MyUploadsViewModel.swift
//  Catty Project
//
//  Created by Сергей Коршунов on 22.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class MyUploadsViewModel {
    let title = "My Uploads"
    private let provider = UploadProvider()

    let onImageChoosen = PublishSubject<Data>()

    let onFileLoaded = PublishSubject<(success: Bool, message: String)>()

    let displayItems = BehaviorSubject(value: [CatCellViewModel]())

    private(set) var storedImages = [CatCellViewModel]()
    private(set) var isLoading = false

    private var page = 0

    init() {
        loadNextPage()
        setupBindings()
    }

    func loadNextPage() {
        isLoading = true
        provider.loadUploadedImages(page: page)
        page += 1
    }

    func deleteImage(index: Int) {
        provider.deleteImage(image_id: storedImages[index].id)
        storedImages.remove(at: index)
        displayItems.onNext(storedImages)
    }

    private let disposeBag = DisposeBag()

    private func setupBindings() {
        provider.catImages.subscribe(onNext: { [weak self] catImages in
            guard let strongSelf = self else { return }
            strongSelf.storedImages.append(contentsOf: catImages)
            strongSelf.displayItems.onNext(strongSelf.storedImages)
        }).disposed(by: disposeBag)

        onImageChoosen.flatMapLatest { [weak self] in
            self?.provider.sendData($0) ?? .empty()
        }.subscribe(onNext: { [weak self] in
            if let url = URL(string: $0) {
                debugPrint(url)
                self?.onFileLoaded.onNext((true, $0))
            } else {
                debugPrint($0)
                self?.onFileLoaded.onNext((false, $0))
            }
            }).disposed(by: disposeBag)

        onFileLoaded.map { $0.success }
            .subscribe(onNext: { [weak self] success in
            guard let strongSelf = self, success else { return }
            strongSelf.page = 0
            strongSelf.storedImages = []
            strongSelf.loadNextPage()
        }).disposed(by: disposeBag)
    }
}
