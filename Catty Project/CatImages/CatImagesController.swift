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
    private let collectionView = CatCollectionView()

    private let filterButton = UIBarButtonItem().style {
        $0.image = UIImage(systemName: "slider.horizontal.3")
    }

    private let refreshControl = UIRefreshControl()

    private let viewModel: CatImagesViewModel

    init(_ viewModel: CatImagesViewModel = CatImagesViewModel()) {
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

        collectionView.refreshControl = refreshControl
        refreshControl.rx.controlEvent(.valueChanged).bind(to: viewModel.onReloadData)
            .disposed(by: disposeBag)

        viewModel.displayItems.map({ $0.isEmpty }).bind(to: refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)

        filterButton.rx.tap.bind(to: viewModel.onFilterButtonTapped).disposed(by: disposeBag)

        viewModel.displayItems
            .bind(to: collectionView.rx.items(cellIdentifier: CatCell.id, cellType: CatCell.self)) { _, model, cell in
                cell.configure(viewModel: model)
        }.disposed(by: disposeBag)

        collectionView.rx.prefetchItems
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] indexPaths in
                guard let strongSelf = self, !strongSelf.viewModel.isLoading else { return }
                for indexPath in indexPaths
                    where indexPath.item + 10 > strongSelf.viewModel.storedItems.count {
                        self?.viewModel.loadNextPage()
                        return
                }
            }).disposed(by: disposeBag)

        collectionView.rx.modelSelected(CatCellViewModel.self)
            .subscribe(onNext: { [weak self] in
                guard let strongSelf = self else { return }
                let nextVC = CatDetailController(viewModel:
                    CatDetailViewModel(image_id: $0.id, image_url: $0.image_url)
                )
                nextVC.hidesBottomBarWhenPushed = true
                strongSelf.navigationController?.pushViewController(nextVC, animated: true)
            }).disposed(by: disposeBag)

        viewModel.onReloadData.subscribe(onNext: { [weak self] in
            self?.collectionView.setContentOffset(CGPoint.zero, animated: true)
        }).disposed(by: disposeBag)

    }
}
