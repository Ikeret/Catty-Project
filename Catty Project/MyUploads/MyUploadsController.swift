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

final class MyUploadsController: UIViewController, UINavigationControllerDelegate {
    
    private let viewModel: MyUploadsViewModel
    
    private let collectionView = CatCollectionView()
        
    private let activityIndicator = UIActivityIndicatorView(style: .large).style {
        $0.size(70)
        $0.backgroundColor = .systemBackground
        $0.hidesWhenStopped = true
        $0.layer.cornerRadius = 10
        $0.layer.borderColor = UIColor.systemGray.cgColor
        $0.layer.borderWidth = 1
    }
    
    private let libraryButton = UIBarButtonItem().style { $0.image = UIImage(systemName: "photo") }
    
    private let cameraButton = UIBarButtonItem().style { $0.image = UIImage(systemName: "camera") }
    
    init(viewModel: MyUploadsViewModel = MyUploadsViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = setupLayout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = viewModel.title
        navigationItem.rightBarButtonItems = [cameraButton, libraryButton]
        
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.setupNormal()
    }
    
    private func setupLayout() -> UIView {
        let view = UIView()
        view.sv(collectionView)
        collectionView.fillContainer()
        
        view.sv(activityIndicator)
        activityIndicator.centerInContainer()
        return view
    }
    
    private let disposeBag = DisposeBag()
    
    private func setupBindings() {
        
        libraryButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.viewModel.showPicker.onNext(.photoLibrary)
        }).disposed(by: disposeBag)
        
        cameraButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.viewModel.showPicker.onNext(.camera)
        }).disposed(by: disposeBag)
        
        viewModel.displayItems.bind(to: collectionView.rx
            .items(cellIdentifier: CatCell.id, cellType: CatCell.self)) { _, model, cell in
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
        
        viewModel.onFileLoaded.map { $0.success }.subscribe(onNext: { [weak self] in
            self?.stopActivity(success: $0)
        }).disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(CatCellViewModel.self)
            .map { CatAnalysisViewModel(image_id: $0.id, image_url: $0.image_url) }
            .bind(to: viewModel.modelSelected)
            .disposed(by: disposeBag)
        
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        
        viewModel.onFilePicked.map {_ in }.subscribe(onNext: { [weak self] in self?.showActivity() })
            .disposed(by: disposeBag)
    }
    
    private func showActivity() {
        activityIndicator.startAnimating()
        cameraButton.isEnabled = false
        libraryButton.isEnabled = false
    }
    
    private func stopActivity(success: Bool) {
        cameraButton.isEnabled = true
        libraryButton.isEnabled = true
        activityIndicator.stopAnimating()
        if success {
            collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
        }
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
