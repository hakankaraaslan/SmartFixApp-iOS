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

    // MARK: - Current User
    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }

    // MARK: - REGISTER
    func register(
        email: String,
        password: String,
        fullName: String,
        role: UserRole,
        completion: @escaping (Result<UserModel, Error>) -> Void
    ) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error {
                completion(.failure(error))
                return
            }

            guard let self,
                  let uid = result?.user.uid else {
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

            self.db.collection("users")
                .document(uid)
                .setData(data) { error in
                    if let error {
                        completion(.failure(error))
                    } else {
                        self.cacheUserSession(uid: uid, completion: completion)
                    }
                }
        }
    }

    // MARK: - LOGIN
    func login(
        email: String,
        password: String,
        completion: @escaping (Result<UserModel, Error>) -> Void
    ) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error {
                completion(.failure(error))
                return
            }

            guard let self,
                  let uid = result?.user.uid else {
                completion(.failure(AuthServiceError.userNotFound))
                return
            }

            self.cacheUserSession(uid: uid, completion: completion)
        }
    }

    // MARK: - LOGOUT
    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            SessionManager.shared.clear()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }

    // MARK: - CACHE USER
    private func cacheUserSession(
        uid: String,
        completion: @escaping (Result<UserModel, Error>) -> Void
    ) {
        FirestoreService.shared.fetchUser(uid: uid) { result in
            switch result {

            case .success(let user):
                // 🔥 LOCAL CACHE
                SessionManager.shared.uid = user.uid
                SessionManager.shared.role = user.role
                SessionManager.shared.isAddressCompleted = user.isAddressCompleted
                SessionManager.shared.currentUser = user

                completion(.success(user))

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

enum AuthServiceError: Error {
    case userNotFound
}
