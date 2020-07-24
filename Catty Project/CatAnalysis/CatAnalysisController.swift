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
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationItem.hidesBackButton = true
        
        let backButton = UIButton().style {
            $0.setTitle("Back", for: .normal)
            $0.setImage(UIImage(systemName: "chevron.left"), for: .normal)
            $0.setTitleColor(.systemBlue, for: .normal)
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 15
            $0.width(70).height(35)
            $0.layer.borderColor = UIColor.systemBlue.cgColor
            $0.layer.borderWidth = 1
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }
    
    private func setupLayout() {
        view.backgroundColor = .systemBackground
        
       
        
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: viewModel.image_url)
        
        let imageHeight: CGFloat = view.bounds.height / 2
        scrollView.contentInset = UIEdgeInsets(top: imageHeight, left: 0, bottom: 0, right: 0)
        
        imageView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: imageHeight)
        view.addSubview(imageView)
        
        view.sv(scrollView)
        
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
                
                let offset = max(0, -contentOffset.y)
                strongSelf.imageView.frame = CGRect(x: 0, y: 0, width: strongSelf.view.bounds.width, height: offset)
                
                //            self?.navigationController?.setNavigationBarHidden(offset > 40, animated: true)
                //            self?.dismissButton.isHidden = offset < 40
                
            }).disposed(by: disposeBag)
    }
}
