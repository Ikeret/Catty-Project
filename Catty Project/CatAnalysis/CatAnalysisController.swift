//
//  CatAnalysisController.swift
//  Catty Project
//
//  Created by Сергей Коршунов on 24.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import UIKit
import Stevia
import RxSwift
import Kingfisher

class CatAnalysisController: UIViewController {
    
    private let imageView = UIImageView().style {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    private let scrollView = UIScrollView().style {
        $0.showsVerticalScrollIndicator = false
    }
    
    private let scrollContent = UIStackView().style {
        $0.axis = .vertical
        $0.spacing = 16
        $0.distribution = .fill
    }
    
    private let viewModel: CatAnalysisViewModel
    
    init(viewModel: CatAnalysisViewModel) {
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
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.setupTranslusent()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.setupNormal()
    }
    
    private func setupLayout() {
        view.backgroundColor = .systemBackground
        
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: viewModel.image_url)
        
        let imageHeight: CGFloat = view.bounds.height / 2
        scrollView.contentInset = UIEdgeInsets(top: imageHeight, left: 0, bottom: 0, right: 0)
        
        imageView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: imageHeight)
        
        view.sv(scrollView)
        view.addSubview(imageView)
        
        scrollView.fillContainer()
        
        scrollContent.width(view.bounds.width - 32)
        scrollView.sv(scrollContent)
        scrollView.layout(
            16,
            |-16-scrollContent,
            50
        )
    }
    
    private let disposeBag = DisposeBag()
    
    private func setupBindings() {
        
        viewModel.displayRows.subscribe(onNext: { [weak self] rows in
            for row in rows {
                self?.scrollContent.addArrangedSubview(row)
            }
        }).disposed(by: disposeBag)
        
        scrollView.rx.contentOffset.skip(1)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] contentOffset in
                guard let strongSelf = self else { return }
                
                let offset = max(80, -contentOffset.y)
                strongSelf.imageView.frame = CGRect(x: 0, y: 0, width: strongSelf.view.bounds.width, height: offset)
                
            }).disposed(by: disposeBag)
    }
}
