//
//  FirestoreService.swift
//  SmartFixApp
//
//  Created by Oğuzhan Abuhanoğlu on 3.05.2026.
//

import Foundation
import FirebaseFirestore

final class FirestoreService {

    static let shared = FirestoreService()
    private init() {}

    private let db = Firestore.firestore()

    func fetchUser(
        uid: String,
        completion: @escaping (Result<UserModel, Error>) -> Void
    ) {
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error {
                completion(.failure(error))
                return
            }

            guard let data = snapshot?.data(),
                  let uid = data["uid"] as? String,
                  let email = data["email"] as? String,
                  let fullName = data["fullName"] as? String,
                  let roleRaw = data["role"] as? String,
                  let role = UserRole(rawValue: roleRaw)
            else {
                completion(.failure(UserDBServiceError.invalidUserData))
                return
            }

            let isAddressCompleted = data["isAddressCompleted"] as? Bool ?? false

            let user = UserModel(
                uid: uid,
                email: email,
                fullName: fullName,
                role: role,
                isAddressCompleted: isAddressCompleted
            )

            completion(.success(user))
        }
    }

    func saveAddress(
        uid: String,
        address: UserAddress,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        db.collection("users")
            .document(uid)
            .updateData([
                "address": address.toDictionary(),
                "isAddressCompleted": true,
                "updatedAt": Timestamp(date: Date())
            ]) { error in
                if let error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
}

enum UserDBServiceError: Error {
    case invalidUserData
}
