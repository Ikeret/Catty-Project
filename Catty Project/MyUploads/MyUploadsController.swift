//
//  MyUploadsController.swift
//  Catty Project
//
//  Created by Сергей Коршунов on 22.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import UIKit
import Stevia
import RxSwift

class MyUploadsController: UIViewController, UINavigationControllerDelegate {

    let viewModel: MyUploadsViewModel

    let collectionView = CatCollectionView()

    let imagePicker = UIImagePickerController()

    let activityIndicator = UIActivityIndicatorView(style: .large).style {
        $0.size(70)
        $0.backgroundColor = .systemBackground
        $0.hidesWhenStopped = true
        $0.layer.cornerRadius = 10
    }

    init(viewModel: MyUploadsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        setupLayout()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = viewModel.title

        setupBindings()

        imagePicker.delegate = self
    }

    private func setupLayout() {
        view.sv(collectionView)
        collectionView.fillContainer()

        view.sv(activityIndicator)
        activityIndicator.centerInContainer()
    }

    let disposeBag = DisposeBag()

    private func setupBindings() {
        let libraryButton = UIBarButtonItem()
        libraryButton.image = UIImage(systemName: "photo")

        libraryButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let picker = self?.imagePicker else { return }
            picker.sourceType = .photoLibrary
            self?.present(picker, animated: true)
        }).disposed(by: disposeBag)

        let cameraButton = UIBarButtonItem()
        cameraButton.image = UIImage(systemName: "camera")

        cameraButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let picker = self?.imagePicker else { return }
            picker.sourceType = .camera
            self?.present(picker, animated: true)
        }).disposed(by: disposeBag)

        navigationItem.rightBarButtonItems = [cameraButton, libraryButton]

        viewModel.onFileLoaded.subscribe(onNext: { [weak self] _ in
            guard let indicator = self?.activityIndicator else { return }
            indicator.stopAnimating()
        }).disposed(by: disposeBag)

        viewModel.displayItems.bind(to: collectionView.rx.items(cellIdentifier: CatCell.id,
                                                                cellType: CatCell.self)) { _, model, cell in
            cell.configure(model: model, showButton: false)
        }.disposed(by: disposeBag)

        collectionView.rx.prefetchItems
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] indexPaths in
                guard let strongSelf = self, !strongSelf.viewModel.isLoading else { return }
                for indexPath in indexPaths where indexPath.item + 10 > strongSelf.viewModel.storedImages.count {
                        self?.viewModel.onLoadNextPage.onNext(())
                        return
                }
            }).disposed(by: disposeBag)

        viewModel.onFileLoaded.subscribe(onNext: { [weak self] in
            if $0.success {
                self?.collectionView.setContentOffset(CGPoint.zero, animated: true)
            } else {
                let alert = UIAlertController(title: "Error", message: $0.message, preferredStyle: .alert)
                alert.addAction(.init(title: "Ok", style: .default, handler: nil))
                self?.present(alert, animated: true)
            }
        }).disposed(by: disposeBag)

        //        collectionView.rx.
    }
}

extension MyUploadsController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let url = info[.imageURL] as? URL {
            debugPrint("library", url.absoluteString)
            viewModel.onUploadFromLibrary.onNext(url)
        } else if let data = (info[.originalImage] as? UIImage)?.jpegData(compressionQuality: 0.8) {
            debugPrint("camera", data.debugDescription)
            viewModel.onUploadFromCamera.onNext(data)
        }
        picker.dismiss(animated: true)
        activityIndicator.startAnimating()
    }
}
