//
//  DetailRowView.swift
//  Catty Project
//
//  Created by Сергей Коршунов on 20.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import UIKit
import Stevia
import RxSwift

final class DetailRowView: UIView {
    private var linkButton: UIButton!
    private var leadingLabel: UILabel!
    private var trailingLabel: UILabel!
    private var stackView: UIStackView!
    
    init(leading: String, trailing: String) {
        super.init(frame: CGRect.zero)
        setupLabels(leading: leading, trailing: trailing)
    }
    
    init(leading: String, stats: Int) {
        super.init(frame: CGRect.zero)
        setupStats(leading: leading, stats: stats)
    }
    
    init(name: String, link: String) {
        super.init(frame: CGRect.zero)
        setupButtons(name: name, link: link)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLabels(leading: String, trailing: String) {
        leadingLabel = UILabel()
        trailingLabel = UILabel()
        stackView = UIStackView()
        
        leadingLabel.text = leading
        leadingLabel.textAlignment = .left
        
        trailingLabel.text = trailing
        trailingLabel.textAlignment = .right
        trailingLabel.numberOfLines = 0
        
        stackView.addArrangedSubview(leadingLabel)
        stackView.addArrangedSubview(trailingLabel)
        
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        
        
        sv(stackView)
        stackView.fillContainer()
    }
    
    private func setupStats(leading: String, stats: Int) {
        leadingLabel = UILabel()
        stackView = UIStackView()
        
        
        let statsStackView = UIStackView()
        statsStackView.distribution = .equalSpacing
        statsStackView.axis = .horizontal
        
        leadingLabel.textAlignment = .left
        leadingLabel.text = leading
        stackView.addArrangedSubview(leadingLabel)
        
        for count in 1...5 {
            if count < stats {
                let filledStar = UIImageView(image: UIImage(systemName: "star.fill"))
                statsStackView.addArrangedSubview(filledStar)
            } else {
                let star = UIImageView(image: UIImage(systemName: "star"))
                star.tintColor = .gray
                statsStackView.addArrangedSubview(star)
            }
        }
        

        
        stackView.addArrangedSubview(statsStackView)
        
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        
        sv(stackView)
        stackView.fillContainer()
    }
    
    private func setupButtons(name: String, link: String) {
        linkButton = UIButton()
        
        linkButton.setTitle(name, for: .normal)
        let image = UIImage(systemName: "link")
        linkButton.setImage(image, for: .normal)
        
        linkButton.backgroundColor = .link
        linkButton.layer.cornerRadius = 15
        linkButton.setTitleColor(.white, for: .normal)
        linkButton.tintColor = .white
        
        linkButton.height(44)
        
        linkButton.rx.tap.subscribe(onNext: {
            if let url = URL(string: link) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
            }).disposed(by: disposeBag)
        
        sv(linkButton)
        linkButton.fillContainer()
    }
    private let disposeBag = DisposeBag()
}
