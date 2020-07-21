//
//  SearchFilterController.swift
//  Catty Project
//
//  Created by Сергей Коршунов on 20.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import UIKit
import RxSwift
import Stevia

class SearchFilterController: UIViewController {
    
    let viewModel: SearchFilterViewModel
    
    let tableView = {
        $0.style { $0.separatorStyle = .none; $0.tableFooterView = UIView(); $0.bounces = false; $0.register(SearchCategoryCell.self, forCellReuseIdentifier: SearchCategoryCell.id)}
    }(UITableView())
    
    let sortTypes = ["RANDOM", "ASC", "DESC"]
    
    let sortControl = { $0.style {
        $0.insertSegment(withTitle: "RANDOM", at: 0, animated: false)
        $0.insertSegment(withTitle: "ASC", at: 1, animated: false)
        $0.insertSegment(withTitle: "DESC", at: 2, animated: false)
        $0.selectedSegmentIndex = 0
        } }(UISegmentedControl())
        
    let gifSwitcher = UISwitch()
    
    let applyButton = {
        $0.style { $0.backgroundColor = .systemBlue; $0.setTitle("Apply", for: .normal); $0.setTitleColor(.white, for: .normal); $0.layer.cornerRadius = 15; $0.height(44) }
    }(UIButton())
    
    init(viewModel: SearchFilterViewModel) {
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = viewModel.title
        setupBindigns()
    }
    
    private func setupLayout() {
        let sortLabel = UILabel().style { $0.text = "Sorted by:" }
        let gifLabel = UILabel().style { $0.text = "Only animated images" }
        let categoryLabel = UILabel().style { $0.text = "Categories"; $0.font = UIFont.systemFont(ofSize: 20, weight: .medium) }
        
        let sortView = UIStackView(arrangedSubviews: [sortLabel, sortControl]).style {
            $0.axis = .horizontal
            $0.distribution = .fill
        }
        let gifView = UIStackView(arrangedSubviews: [gifLabel, gifSwitcher]).style {
            $0.axis = .horizontal
            $0.distribution = .fill
        }

        view.sv(tableView, categoryLabel, sortView, gifView, applyButton)
        
        view.layout(
            175,
            |-16-sortView-16-|,
            32,
            |-16-gifView-16-|,
            50,
            |-8-categoryLabel,
            8,
            |-tableView-|,
            16,
            |-16-applyButton-16-|,
            40
        )
    }
    
    let disposeBag = DisposeBag()
    
    private func setupBindigns() {
        sortControl.selectedSegmentIndex = sortTypes.firstIndex(of: viewModel.sorting) ?? 0
        gifSwitcher.isOn = viewModel.onlyGif
        
        viewModel.categories.bind(to: tableView.rx.items(cellIdentifier: SearchCategoryCell.id, cellType: SearchCategoryCell.self)) { row, model, cell in
            cell.titleLabel.text = model.name.capitalized
            cell.selectionStyle = .none
            cell.categoryId = model.id
        }.disposed(by: disposeBag)
        
        tableView.rx.willDisplayCell.subscribe(onNext: { [weak self] in
            guard let strongSelf = self else { return }
            let cell = $0.cell as! SearchCategoryCell
            if cell.categoryId == strongSelf.viewModel.categoryId {
                strongSelf.tableView.selectRow(at: $0.indexPath, animated: true, scrollPosition: .none)
            }
            }).disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Category.self).bind(to: viewModel.selectedCategory).disposed(by: disposeBag)
        
        sortControl.rx.selectedSegmentIndex.skip(1).subscribe(onNext: { [weak self] in
            guard let strongSelf = self else { return }
            self?.viewModel.selectedSort.onNext(strongSelf.sortTypes[$0])
        }).disposed(by: disposeBag)
        
        gifSwitcher.rx.isOn.skip(1).subscribe(onNext: { [weak self] in
            self?.viewModel.gifIsOn.onNext($0)
        }).disposed(by: disposeBag)
        
        applyButton.rx.tap.bind(to: viewModel.onApplySettings).disposed(by: disposeBag)
        applyButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
            }).disposed(by: disposeBag)
    }
}
