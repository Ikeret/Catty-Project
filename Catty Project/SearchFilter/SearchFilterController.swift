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
        $0.style { $0.separatorStyle = .none; $0.allowsMultipleSelection = true }
    }(UITableView())
    
    let sortControl = { $0.style {
        $0.insertSegment(withTitle: "Random", at: 0, animated: false)
        $0.insertSegment(withTitle: "ASC", at: 1, animated: false)
        $0.insertSegment(withTitle: "DESC", at: 2, animated: false)
        $0.selectedSegmentIndex = 0
        } }(UISegmentedControl())
        
    let gifSwitcher = UISwitch()
    
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
        navigationController?.navigationBar.isTranslucent = false
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
        
        let sortView = UIStackView(arrangedSubviews: [sortLabel, sortControl]).style {
            $0.spacing = 8
            $0.axis = .vertical
        }
        let gifView = UIStackView(arrangedSubviews: [gifLabel, gifSwitcher]).style {
            $0.axis = .horizontal
            $0.distribution = .fillProportionally
        }

        view.sv(tableView, sortView, gifView)
        tableView.bounces = false
        
        view.layout(
            20,
            |-50-sortView-50-|,
            32,
            |-50-gifView-50-|,
            50,
            |-tableView-|,
            0
            
            
        )
    }
    
    let disposeBag = DisposeBag()
    
    private func setupBindigns() {
        viewModel.categories.bind(to: tableView.rx.items) { table, index, element in
            let cell = UITableViewCell(style: .default, reuseIdentifier: "categoryCell")
            cell.textLabel?.text = element.name.capitalized
            return cell
        }.disposed(by: disposeBag)
        
//        tableView.rx.itemSelected.subscribe(onNext: { [weak self] in
//            }).disposed(by: disposeBag)
        
    }
}
