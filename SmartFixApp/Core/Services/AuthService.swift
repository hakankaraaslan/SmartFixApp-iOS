//
//  AuthService.swift
//  SmartFixApp
//
//  Created by Ahmet Hakan Karaaslan on 10.03.2026.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final class AuthService {

    static let shared = AuthService()
    private init() {}

    private let db = Firestore.firestore()

    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }

    func register(
        email: String,
        password: String,
        fullName: String,
        role: UserRole,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error {
                completion(.failure(error))
                return
            }

            guard let uid = result?.user.uid else {
                completion(.failure(AuthServiceError.userNotFound))
                return
            }

            let data: [String: Any] = [
                "uid": uid,
                "email": email,
                "fullName": fullName,
                "role": role.rawValue,
                "isAddressCompleted": false,
                "createdAt": Timestamp(date: Date())
            ]

            self?.db.collection("users")
                .document(uid)
                .setData(data) { error in
                    if let error {
                        completion(.failure(error))
                    } else {
                        completion(.success(uid))
                    }
                }
        }
    }

    func login(
        email: String,
        password: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error {
                completion(.failure(error))
                return
            }

            guard let uid = result?.user.uid else {
                completion(.failure(AuthServiceError.userNotFound))
                return
            }

            completion(.success(uid))
        }
    }

    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            SessionManager.shared.clear()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchUserRole(
        uid: String,
        completion: @escaping (Result<UserRole, Error>) -> Void
    ) {
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error {
                completion(.failure(error))
                return
            }

            guard
                let data = snapshot?.data(),
                let roleRawValue = data["role"] as? String,
                let role = UserRole(rawValue: roleRawValue)
            else {
                completion(.failure(AuthServiceError.userNotFound))
                return
            }

            completion(.success(role))
        }
    }
}

enum AuthServiceError: Error {
    case userNotFound
}
