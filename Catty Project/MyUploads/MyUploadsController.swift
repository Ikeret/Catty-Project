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

    private let viewModel: MyUploadsViewModel

    private let collectionView = CatCollectionView()

    private let imagePicker = UIImagePickerController()

    private let activityIndicator = UIActivityIndicatorView(style: .large).style {
        $0.size(70)
        $0.backgroundColor = .systemBackground
        $0.hidesWhenStopped = true
        $0.layer.cornerRadius = 10
    }

    private let libraryButton = UIBarButtonItem().style { $0.image = UIImage(systemName: "photo") }

    private let cameraButton = UIBarButtonItem().style { $0.image = UIImage(systemName: "camera") }

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
        navigationItem.rightBarButtonItems = [cameraButton, libraryButton]

        setupBindings()

        imagePicker.delegate = self
    }

    private func setupLayout() {
        view.sv(collectionView)
        collectionView.fillContainer()

        view.sv(activityIndicator)
        activityIndicator.centerInContainer()
    }

    private let disposeBag = DisposeBag()

    private func setupBindings() {

        libraryButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let picker = self?.imagePicker else { return }
            picker.sourceType = .photoLibrary
            self?.present(picker, animated: true)
        }).disposed(by: disposeBag)

        cameraButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let picker = self?.imagePicker else { return }
            picker.sourceType = .camera
            self?.present(picker, animated: true)
        }).disposed(by: disposeBag)

        viewModel.onFileLoaded.subscribe(onNext: { [weak self] _ in
            guard let indicator = self?.activityIndicator else { return }
            indicator.stopAnimating()
        }).disposed(by: disposeBag)

        viewModel.displayItems.bind(to: collectionView.rx.items(cellIdentifier: CatCell.id,
                                                                cellType: CatCell.self)) { _, model, cell in
            cell.configure(viewModel: model, showButton: false)
        }.disposed(by: disposeBag)

        collectionView.rx.prefetchItems
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] indexPaths in
                guard let strongSelf = self, !strongSelf.viewModel.isLoading else { return }
                for indexPath in indexPaths
                    where indexPath.item + 10 > strongSelf.viewModel.storedImages.count {
                        self?.viewModel.loadNextPage()
                        return
                }
            }).disposed(by: disposeBag)

        viewModel.onFileLoaded.subscribe(onNext: { [weak self] in
            self?.cameraButton.isEnabled = true
            self?.libraryButton.isEnabled = true
            if $0.success {
                self?.collectionView.setContentOffset(CGPoint.zero, animated: true)
            } else {
                let alert = UIAlertController(title: "Error", message: $0.message, preferredStyle: .alert)
                alert.addAction(.init(title: "Ok", style: .default, handler: nil))
                self?.present(alert, animated: true)
            }
        }).disposed(by: disposeBag)

        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
    }
}

extension MyUploadsController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            let size = image.size
            if size.height > 1920 || size.width > 1080 {
                let resizedImage = image.kf.resize(to: CGSize(width: 1920,
                                                              height: 1080),
                                                   for: .aspectFit)
                if let data = resizedImage.jpegData(compressionQuality: 0.8) {
                    viewModel.onImageChoosen.onNext(data)
                }
            } else if let data = image.jpegData(compressionQuality: 0.8) {
                viewModel.onImageChoosen.onNext(data)
            }

        }
        picker.dismiss(animated: true)

        activityIndicator.startAnimating()
        cameraButton.isEnabled = false
        libraryButton.isEnabled = false
    }
}

extension MyUploadsController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let deleteAction = UIAction(title: "Delete",
                                        image: UIImage(systemName: "trash"),
                                        attributes: .destructive) { [weak self] _ in
                self?.viewModel.deleteImage(index: indexPath.item)
            }
            return UIMenu(title: "", children: [deleteAction])
        }

    }
}
