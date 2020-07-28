//
//  SearchCategoryCell.swift
//  Catty Project
//
//  Created by Сергей Коршунов on 21.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import UIKit
import Stevia

class SearchCategoryCell: UITableViewCell {
    static let id = "CategoryCell"

    private let titleLabel: UILabel
    private(set) var categoryId: Int = -1

    private let selectedView: UIView

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        titleLabel = UILabel().style { $0.font = UIFont.systemFont(ofSize: 18, weight: .medium) }
        selectedView = UIView().style { $0.layer.masksToBounds = true; $0.layer.cornerRadius = 10 }
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        sv(selectedView.sv(titleLabel))
        selectedView.fillContainer(5)
        selectedView.layout(
            0,
            |-16-titleLabel.height(40)-16-|,
            0
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String, categoryId: Int) {
        titleLabel.text = title
        self.categoryId = categoryId
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            titleLabel.textColor = .white
            selectedView.backgroundColor = .systemBlue
        } else {
            titleLabel.textColor = .label
            selectedView.backgroundColor = .lightGray
        }
    }
}
