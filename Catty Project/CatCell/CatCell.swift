//
//  CatCell.swift
//  Catty Project
//
//  Created by Сергей Коршунов on 15.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import UIKit
import RxSwift
import AlamofireImage
import Stevia
import Kingfisher

class CatCell: UICollectionViewCell {
    static let id = "CatCell"
    
    private let catImageView: UIImageView
    private let shadowView = UIImageView(image: UIImage(named: "Shadow"))
    
    private let favouriteButton: UIButton
    
    
    var disposeBag = DisposeBag()
    
    private var model: CatCellViewModel!
    
    
    override init(frame: CGRect) {
        catImageView = UIImageView()
        favouriteButton = UIButton()
        favouriteButton.isHidden = true
        shadowView.isHidden = true
        super.init(frame: frame)
        
        sv(catImageView, shadowView, favouriteButton)
        shadowView.fillContainer()
        
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupLayout()
    }
    
    func configure(model: CatCellViewModel, showButton: Bool = true) {
        self.model = model
        
        guard let url = model.image_url else { return }
        let cellSize = contentView.bounds.size
        let imageSize = CGSize(width: cellSize.width * UIScreen.main.scale, height: cellSize.height * UIScreen.main.scale)
        
        catImageView.kf.setImage(with: url, options: [ .cacheOriginalImage, .onlyLoadFirstFrame, .processor(DownsamplingImageProcessor(size: imageSize))]) { [weak self] _ in
            self?.favouriteButton.isHidden = !showButton
            self?.shadowView.isHidden = !showButton
        }
        
        let heartImage = UIImage(systemName: model.favImageName)
        favouriteButton.setBackgroundImage(heartImage, for: .normal)
        
        
        setupBindings()
    }
    
    private func setupLayout() {
        catImageView.fillContainer()
        
        catImageView.contentMode = .scaleAspectFill
        catImageView.layer.cornerRadius = 10
        catImageView.clipsToBounds = true
        catImageView.layout(
            favouriteButton-5-|,
            5
        )
        
        favouriteButton.size(50)
        favouriteButton.tintColor = .systemPink
        favouriteButton.clipsToBounds = true
        favouriteButton.subviews.first?.contentMode = .scaleAspectFit
    }
    
    private func setupBindings() {
        favouriteButton.rx.tap.bind(to: model.onChangeFavourite).disposed(by: disposeBag)
        favouriteButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let strongSelf = self else { return }
            let heartImage = UIImage(systemName: strongSelf.model.favImageName)
            strongSelf.favouriteButton.setBackgroundImage(heartImage, for: .normal)
        }).disposed(by: disposeBag)
    }
}
