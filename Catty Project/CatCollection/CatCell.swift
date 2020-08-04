//
//  CatCell.swift
//  Catty Project
//
//  Created by Сергей Коршунов on 15.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import UIKit
import RxSwift
import Stevia
import Kingfisher

final class CatCell: UICollectionViewCell {
    static let id = "CatCell"

    private let catImageView: UIImageView
    private let shadowView = UIImageView(image: UIImage(named: "Shadow"))

    private let favouriteButton: UIButton

    var disposeBag = DisposeBag()

    private var viewModel: CatCellViewModel!

    override init(frame: CGRect) {
        catImageView = UIImageView()
        favouriteButton = UIButton()
        favouriteButton.isHidden = true
        shadowView.isHidden = true
        super.init(frame: frame)
        setupLayout()
        accessibilityIdentifier = "CatCell"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        catImageView.kf.cancelDownloadTask()
        favouriteButton.isHidden = true
        shadowView.isHidden = true
    }

    func configure(viewModel: CatCellViewModel, showButton: Bool = true) {
        self.viewModel = viewModel

        guard let url = viewModel.image_url else { return }
        let cellSize = contentView.bounds.size

        catImageView.kf.indicatorType = .activity
        catImageView.kf.setImage(with: url, options: [
                                    .processor(DownsamplingImageProcessor(size: cellSize)),
                                    .scaleFactor(UIScreen.main.scale), .cacheOriginalImage,
                                    .originalCache(.default)]) { [weak self] _ in
            self?.favouriteButton.isHidden = !showButton
            self?.shadowView.isHidden = !showButton
        }

        let heartImage = UIImage(systemName: viewModel.favImageName)
        favouriteButton.setBackgroundImage(heartImage, for: .normal)
        favouriteButton.accessibilityIdentifier = viewModel.favImageName

        setupBindings()
    }

    private func setupLayout() {
        sv(catImageView, shadowView, favouriteButton)
        shadowView.fillContainer()

        backgroundColor = .systemBackground
        shadowView.layer.cornerRadius = 10
        shadowView.clipsToBounds = true

        catImageView.fillContainer()

        catImageView.contentMode = .scaleAspectFill
        catImageView.layer.cornerRadius = 10
        catImageView.clipsToBounds = true
        catImageView.layout(
            favouriteButton-5-|,
            5
        )

        favouriteButton.height(50).width(55)
        favouriteButton.tintColor = .systemPink
        favouriteButton.clipsToBounds = true
        favouriteButton.subviews.first?.contentMode = .scaleAspectFit
    }

    private func setupBindings() {
        favouriteButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.changeFavourite()
            
            let favButton = strongSelf.favouriteButton
            
            if favButton.currentBackgroundImage == UIImage(systemName: "heart") {
                favButton.setBackgroundImage(UIImage(systemName: "heart.fill"), for: .normal)
                favButton.accessibilityIdentifier = "heart.fill"
            } else {
                favButton.setBackgroundImage(UIImage(systemName: "heart"), for: .normal)
                favButton.accessibilityIdentifier = "heart"
            }
        }).disposed(by: disposeBag)
    }
}
