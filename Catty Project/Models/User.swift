//
//  User.swift
//  Catty Project
//
//  Created by Сергей Коршунов on 15.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import Foundation

final class User {
    private init() {}
    
    static let shared = User()
    
    private(set) var name: String = ""
    private(set) var sub_id: String = ""
    
    private var users: [String: String] {
        get { UserDefaults.standard.dictionary(forKey: "users") as? [String: String] ?? ["": ""] }
        set { UserDefaults.standard.set(newValue, forKey: "users") }
    }
    
    var sorting: String {
        get { UserDefaults.standard.string(forKey: "\(name) sorting") ?? "RANDOM" }
        set { UserDefaults.standard.set(newValue, forKey: "\(name) sorting") }
    }
    
    var onlyGif: Bool {
        get { UserDefaults.standard.bool(forKey: "\(name) gif") }
        set { UserDefaults.standard.set(newValue, forKey: "\(name) gif") }
    }
    
    var categoryId: Int {
        get { UserDefaults.standard.integer(forKey: "\(name) categories") }
        set { UserDefaults.standard.set(newValue, forKey: "\(name) categories") }
    }
    
    var lastUser: String? {
        get { UserDefaults.standard.string(forKey: "lastUser") }
        set { UserDefaults.standard.set(newValue, forKey: "lastUser") }
    }
    
    func registerLastUser() -> Bool {
        if let name = lastUser {
            registerUser(name: name)
            return true
        }
        return false
    }
    
    func registerUser(name: String) {
        self.name = name
        lastUser = name
        if let sub_id = users[name] {
            self.sub_id = sub_id
        } else {
            sub_id = "id\(name.hash)"
            users[name] = sub_id
        }
    }
    
    func logOut() {
        DataProvider.refreshShared()
        lastUser = nil
        name = ""
        sub_id = ""
    }
}
