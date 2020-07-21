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
    static private(set) var sub_id: String = "test2"
    
    static private var users: [String: String] {
        get {
            UserDefaults.standard.dictionary(forKey: "users") as? [String : String] ?? ["":""]
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "users")
        }
    }
    
    class func isUserRegistered(name: String) -> Bool {
        return users[name] != nil
    }
    
    class func registerUser(name: String) {
        self.name = name
        sub_id = UUID().uuidString
        users[name] = sub_id
    }
}
