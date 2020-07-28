//
//  LoginViewModel.swift
//  Catty Project
//
//  Created by Сергей Коршунов on 22.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import Foundation
import RxSwift

final class LoginViewModel {    
    let registerUser = PublishSubject<String>()
    
    init() {
        registerUser.subscribe(onNext: User.registerUser(name:)).disposed(by: disposeBag)
    }
    
    private let disposeBag = DisposeBag()
}
