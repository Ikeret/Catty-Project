//
//  CatCollectionView.swift
//  Catty Project
//
//  Created by Сергей Коршунов on 23.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import UIKit

class CatCollectionView: UICollectionView {

    init() {
        let flowLayout = UICollectionViewFlowLayout()
        super.init(frame: CGRect.zero, collectionViewLayout: flowLayout)

        let width = UIScreen.main.bounds.width / 2 - 16
        flowLayout.itemSize = CGSize(width: width, height: width)
        flowLayout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        register(CatCell.self, forCellWithReuseIdentifier: CatCell.id)
        backgroundColor = .systemBackground
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
