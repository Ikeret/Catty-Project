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

    static private(set) var name: String = ""
    static private(set) var sub_id: String = ""

    static private var users: [String: String] {
        get { UserDefaults.standard.dictionary(forKey: "users") as? [String: String] ?? ["": ""] }
        set { UserDefaults.standard.set(newValue, forKey: "users") }
    }

    static var sorting: String {
        get { UserDefaults.standard.string(forKey: "\(name) sorting") ?? "RANDOM" }
        set { UserDefaults.standard.set(newValue, forKey: "\(name) sorting") }
    }

    static var onlyGif: Bool {
        get { UserDefaults.standard.bool(forKey: "\(name) gif") }
        set { UserDefaults.standard.set(newValue, forKey: "\(name) gif") }
    }

    static var categoryId: Int {
        get { UserDefaults.standard.integer(forKey: "\(name) categories") }
        set { UserDefaults.standard.set(newValue, forKey: "\(name) categories") }
    }
    
    private static var lastUser: String? {
        get { UserDefaults.standard.string(forKey: "lastUser") }
        set { UserDefaults.standard.set(newValue, forKey: "lastUser") }
    }
    
    class func registerLastUser() -> Bool {
        if let name = lastUser {
            registerUser(name: name)
            return true
        }
        return false
    }

    class func registerUser(name: String) {
        self.name = name
        lastUser = name
        if let sub_id = users[name] {
            self.sub_id = sub_id
        } else {
            sub_id = UUID().uuidString
            users[name] = sub_id
        }
    }
    
    class func logOut() {
        DataProvider.refreshShared()
        lastUser = nil
        name = ""
        sub_id = ""
    }
}
