//
//  CatDetailController.swift
//  Catty Project
//
//  Created by Сергей Коршунов on 17.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import UIKit
import RxSwift
import Stevia

class CatDetailController: UIViewController {
    private let viewModel: CatDetailViewModel
    
    private let imageView = {
        $0.style { $0.contentMode = .scaleAspectFill; $0.clipsToBounds = true }
    }(UIImageView())
    
    private let buttonLike = {
        $0.style { $0.setTitle("👍", for: .normal); $0.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.7); $0.layer.cornerRadius = 15; $0.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        }
    }(UIButton())
    
    private let buttonDislike = {
        $0.style { $0.setTitle("👎", for: .normal); $0.backgroundColor = UIColor.systemPink.withAlphaComponent(0.7); $0.layer.cornerRadius = 15; $0.titleLabel?.font = UIFont.systemFont(ofSize: 32) }
    }(UIButton())
    
    private let scrollView = {
        $0.style { $0.showsVerticalScrollIndicator = false }
    }(UIScrollView())
    
    private let buttonsStack = {
        $0.style { $0.spacing = 16; $0.axis = .horizontal; $0.distribution = .fillEqually; $0.isHidden = true}
    }(UIStackView())
    
    private let scrollContent = {
        $0.style { $0.spacing = 16; $0.axis = .vertical }
    }(UIStackView())
    
    init(viewModel: CatDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        setupLayout()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }
    
    private func setupLayout() {
        imageView.kf.setImage(with: viewModel.image_url)
        imageView.kf.indicatorType = .activity
        
        let imageHeight: CGFloat = min(viewModel.imageHeight, view.bounds.height - 150)
        scrollView.contentInset = UIEdgeInsets(top: imageHeight, left: 0, bottom: 0, right: 0)
        
        imageView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: imageHeight)
        view.sv(scrollView)
        view.addSubview(imageView)
        scrollView.fillContainer()
        
        // MARK: Scroll View
        
        scrollContent.width(view.bounds.width - 32)
        scrollView.sv(scrollContent)
        scrollView.layout(
            8,
            |-16-scrollContent,
            50
        )
        
        // MARK: Scroll View Content
        
        buttonsStack.addArrangedSubview(buttonDislike)
        buttonsStack.addArrangedSubview(buttonLike)
        
        scrollContent.addArrangedSubview(buttonsStack)
        
    }
    
    private func subviewDetailInfo() {
        let topLabel = UILabel()
        topLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        scrollContent.addArrangedSubview(topLabel)
        guard !viewModel.detailInfo.isEmpty else {
            topLabel.text = "No detail info" 
            return
        }
        topLabel.text = "Breeds on picture"
        
        
        
        let detailContent = UIStackView()
            .style {$0.axis = .vertical; $0.distribution = .fill; $0.spacing = 16}
        
        for i in 0..<viewModel.detailInfo.count {
            let info = viewModel.detailInfo[i]
            let stats = viewModel.detailStats[i]
            let links = viewModel.detailLinks[i]
            
            for row in info {
                detailContent.addArrangedSubview(DetailRowView(leading: row.name, trailing: row.value))
            }
            
            for row in stats {
                detailContent.addArrangedSubview(DetailRowView(leading: row.name, stats: row.value))
            }
            
            for row in links {
                detailContent.addArrangedSubview(DetailRowView(name: row.key, link: row.value))
            }
        }
        
        scrollContent.addArrangedSubview(detailContent)
    }
    
    private func setupVotes() {
        if let vote = viewModel.vote {
            buttonDislike.isHidden = vote.value == 1
            buttonLike.isHidden = vote.value != 1
            buttonsStack.isUserInteractionEnabled = false
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.buttonsStack.isHidden = false
        })
    }
    
    private let disposeBag = DisposeBag()
    private func setupBindings() {
        buttonLike.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let strongSelf = self else { return }
            
            strongSelf.viewModel.onVoteChanged.onNext(1)
            strongSelf.buttonsStack.isUserInteractionEnabled = false
            
            UIView.animate(withDuration: 0.5) {
                strongSelf.buttonDislike.isHidden = true
            }
        }).disposed(by: disposeBag)
        
        buttonDislike.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let strongSelf = self else { return }
            
            strongSelf.viewModel.onVoteChanged.onNext(0)
            strongSelf.buttonsStack.isUserInteractionEnabled = false
            
            
            UIView.animate(withDuration: 0.5) {
                strongSelf.buttonLike.isHidden = true
            }
        }).disposed(by: disposeBag)
        
        scrollView.rx.contentOffset.subscribe(onNext: { [weak self] contentOffset in
            guard let strongSelf = self else { return }
            
            let offset = max(0, -contentOffset.y)
            strongSelf.imageView.frame = CGRect(x: 0, y: 0, width: strongSelf.view.bounds.width, height: offset)
            
        }).disposed(by: disposeBag)
        
        viewModel.onDetailLoaded
            .observeOn(MainScheduler.instance)
            .subscribe(onCompleted: { [weak self] in self?.subviewDetailInfo()})
            .disposed(by: disposeBag)
        
        viewModel.onVoteLoaded
            .observeOn(MainScheduler.instance)
            .subscribe(onCompleted: { [weak self] in self?.setupVotes()})
            .disposed(by: disposeBag)
    }
    
}
