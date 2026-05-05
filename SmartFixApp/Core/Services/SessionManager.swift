//
//  SessionManager.swift
//  SmartFixApp
//
//  Created by Oğuzhan Abuhanoğlu on 3.05.2026.
//

import Foundation

final class SessionManager {
    static let shared = SessionManager()
    private init() {}

    private let defaults = UserDefaults.standard

    var currentUser: UserModel? {
        get {
            guard let data = defaults.data(forKey: "currentUser"),
                  let user = try? JSONDecoder().decode(UserModel.self, from: data)
            else { return nil }
            return user
        }
        set {
            if let newValue,
               let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: "currentUser")
            } else {
                defaults.removeObject(forKey: "currentUser")
            }
        }
    }
    
    var uid: String? {
        get { defaults.string(forKey: "uid") }
        set { defaults.set(newValue, forKey: "uid") }
    }

    var role: UserRole? {
        get {
            guard let raw = defaults.string(forKey: "role") else { return nil }
            return UserRole(rawValue: raw)
        }
        set {
            defaults.set(newValue?.rawValue, forKey: "role")
        }
    }

    var isAddressCompleted: Bool {
        get { defaults.bool(forKey: "isAddressCompleted") }
        set { defaults.set(newValue, forKey: "isAddressCompleted") }
    }

    func clear() {
        defaults.removeObject(forKey: "uid")
        defaults.removeObject(forKey: "role")
        defaults.removeObject(forKey: "isAddressCompleted")
    }
}
