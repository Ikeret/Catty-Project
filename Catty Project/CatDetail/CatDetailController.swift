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

final class CatDetailController: UIViewController {
    private let viewModel: CatDetailViewModel

    private let imageView = UIImageView().style { $0.contentMode = .scaleAspectFill; $0.clipsToBounds = true }

    private let buttonLike = UIButton().style {
        $0.setTitle("👍", for: .normal)
        $0.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.7)
        $0.layer.cornerRadius = 15
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 32)
    }

    private let buttonDislike = UIButton().style {
        $0.setTitle("👎", for: .normal)
        $0.backgroundColor = UIColor.systemPink.withAlphaComponent(0.7)
        $0.layer.cornerRadius = 15
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 32)
    }

    private let scrollView = UIScrollView().style { $0.showsVerticalScrollIndicator = false }

    private let buttonsStack = UIStackView().style {
        $0.spacing = 16; $0.axis = .horizontal; $0.distribution = .fillEqually; $0.alpha = 0
    }

    private let scrollContent = UIStackView().style { $0.spacing = 16; $0.axis = .vertical }

    init(viewModel: CatDetailViewModel) {
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
        setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.setupTranslusent()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.setupNormal()
    }

    private func setupLayout() -> UIView {
        let view = UIView()
        view.backgroundColor = .systemBackground

        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: viewModel.image_url, options: [])

        let imageHeight: CGFloat = UIScreen.main.bounds.height / 2
        scrollView.contentInset = UIEdgeInsets(top: imageHeight, left: 0, bottom: 0, right: 0)

        imageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: imageHeight)
        view.sv(scrollView)
        view.addSubview(imageView)


        scrollView.fillContainer()

        // MARK: Scroll View

        scrollContent.width(UIScreen.main.bounds.width - 32)
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
        return view
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

        for breed in 0..<viewModel.detailInfo.count {
            let info = viewModel.detailInfo[breed]
            let stats = viewModel.detailStats[breed]
            let links = viewModel.detailLinks[breed]

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
            self.buttonsStack.alpha = 1
        })
    }

    private let disposeBag = DisposeBag()
    
    private func setupBindings() {
        buttonLike.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let strongSelf = self else { return }

            strongSelf.viewModel.changeVote(newValue: 1)
            strongSelf.buttonsStack.isUserInteractionEnabled = false

            UIView.animate(withDuration: 0.5, animations: {
                strongSelf.buttonDislike.alpha = 0
                strongSelf.buttonDislike.isHidden = true
            })
        }).disposed(by: disposeBag)

        buttonDislike.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let strongSelf = self else { return }

            strongSelf.viewModel.changeVote(newValue: 0)
            strongSelf.buttonsStack.isUserInteractionEnabled = false

            UIView.animate(withDuration: 0.5, animations: {
                strongSelf.buttonLike.alpha = 0
                strongSelf.buttonLike.isHidden = true
            })
        }).disposed(by: disposeBag)

        scrollView.rx.contentOffset.skip(1)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] contentOffset in
                guard let strongSelf = self else { return }

                let offset = max(80, -contentOffset.y)
                strongSelf.imageView.frame = CGRect(x: 0, y: 0, width: strongSelf.view.bounds.width, height: offset)

            }).disposed(by: disposeBag)

        viewModel.onDetailLoaded.observeOn(MainScheduler.instance)
            .subscribe(onCompleted: { [weak self] in self?.subviewDetailInfo() }).disposed(by: disposeBag)

        viewModel.onVoteLoaded.observeOn(MainScheduler.instance)
            .subscribe(onCompleted: { [weak self] in self?.setupVotes() }).disposed(by: disposeBag)
    }
}
