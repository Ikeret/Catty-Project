//
//  LoginController.swift
//  Catty Project
//
//  Created by Сергей Коршунов on 22.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import UIKit
import RxSwift
import Stevia

class LoginController: UIViewController {
    
    let viewModel: LoginViewModel
    
    init(_ viewModel: LoginViewModel = LoginViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let titleLabel = UILabel().style {
        $0.text = "Catty Project"
        $0.font = UIFont.systemFont(ofSize: 32, weight: .black)
        $0.textAlignment = .center
    }

    private let loginTextField = UITextField().style {
        $0.height(44)
        $0.layer.cornerRadius = 15
        $0.width(UIScreen.main.bounds.size.width - 32)
        $0.backgroundColor = .secondarySystemBackground
        $0.textAlignment = .center
        $0.placeholder = "Enter a name or login"
    }
    
    private let loginButton = UIButton().style {
        $0.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        $0.tintColor = .white
        $0.height(44)
        $0.width(70)
        $0.backgroundColor = .systemBlue
        $0.layer.cornerRadius = 15
        $0.isEnabled = false
    }

    override func loadView() {
        view = setupLayout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }
    
    private func setupLayout() -> UIView {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.sv(titleLabel, loginTextField)
        loginTextField.centerInContainer()
        
        titleLabel.centerHorizontally()
        titleLabel.centerVertically(-100)
        
        loginTextField.rightView = loginButton
        loginTextField.rightViewMode = .always
        return view
    }
    
    let disposeBag = DisposeBag()
    
    private func setupBindings() {
        loginTextField.rx.text.orEmpty
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { $0.count > 2 }
            .bind(to: loginButton.rx.isEnabled).disposed(by: disposeBag)
        
        loginButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.viewModel.registerUser.onNext(self?.loginTextField.text ?? "")
        }).disposed(by: disposeBag)
    }
}
