//
//  AuthService.swift
//  SmartFixApp
//
//  Created by Ahmet Hakan Karaaslan on 10.03.2026.
//

import Foundation

final class AuthService {

    static let shared = AuthService()

    private init() {}

    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {

        // MOCK LOGIN (Firebase gelene kadar)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(true)
        }

    }

    func register(email: String, password: String, completion: @escaping (Bool) -> Void) {

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(true)
        }

    }

}
