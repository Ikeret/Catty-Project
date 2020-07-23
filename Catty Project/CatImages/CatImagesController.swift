//
//  CatCollectionController.swift
//  Catty Project
//
//  Created by Сергей Коршунов on 15.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CatImagesController: UIViewController {
    let collectionView = CatCollectionView()

    let filterButton = UIBarButtonItem().style {
        $0.image = UIImage(systemName: "slider.horizontal.3")
    }

    let viewModel: CatImagesViewModel

    init(viewModel: CatImagesViewModel) {
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
        navigationItem.setRightBarButton(filterButton, animated: false)

        setupBindigs()
    }

    private func setupLayout() {
        view.sv(collectionView)
        collectionView.fillContainer()
    }

    private let disposeBag = DisposeBag()

    private func setupBindigs() {

        filterButton.rx.tap.subscribe(onNext: {
            let model = SearchFilterViewModel()
            let filterVC = SearchFilterController(viewModel: model)
            model.onSettingsChanged.bind(to: self.viewModel.onSettingsChanged).disposed(by: self.disposeBag)
            filterVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(filterVC, animated: true)
        }).disposed(by: disposeBag)

        viewModel.displayItems
            .bind(to: collectionView.rx.items(cellIdentifier: CatCell.id, cellType: CatCell.self)) { _, model, cell in
                cell.configure(model: model)
        }.disposed(by: disposeBag)

        collectionView.rx.prefetchItems
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] indexPaths in
                guard let strongSelf = self, !strongSelf.viewModel.isLoading else { return }
                for indexPath in indexPaths where indexPath.item + 10 > strongSelf.viewModel.storedItems.count {
                        self?.viewModel.onLoadNextPage.onNext(())
                        return
                }
            }).disposed(by: disposeBag)

        collectionView.rx.modelSelected(CatCellViewModel.self)
            .subscribe(onNext: { [weak self] in
                guard let strongSelf = self else { return }
                let nextVC = CatDetailController(viewModel:
                    CatDetailViewModel(image_id: $0.id,
                                       image_url: $0.image_url,
                                       size: $0.size)
                )
                nextVC.hidesBottomBarWhenPushed = true
                strongSelf.navigationController?.pushViewController(nextVC, animated: true)
            }).disposed(by: disposeBag)

        viewModel.onSettingsChanged.subscribe(onNext: { [weak self] in
            self?.collectionView.setContentOffset(CGPoint.zero, animated: true)
        }).disposed(by: disposeBag)
    }
}
