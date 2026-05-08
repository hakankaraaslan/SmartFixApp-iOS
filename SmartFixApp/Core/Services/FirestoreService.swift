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

            let addressesData = data["addresses"] as? [[String: Any]] ?? []

            let addresses = addressesData.compactMap {
                UserAddress.fromDictionary($0)
            }
            
            let user = UserModel(
                uid: uid,
                email: email,
                fullName: fullName,
                role: role,
                isAddressCompleted: isAddressCompleted,
                addresses: addresses
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
                "addresses": FieldValue.arrayUnion([
                    address.toDictionary()
                ]),
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
    
    func fetchUserAddresses(
        uid: String,
        completion: @escaping (Result<[UserAddress], Error>) -> Void
    ) {
        db.collection("users")
            .document(uid)
            .getDocument { snapshot, error in

                if let error {
                    completion(.failure(error))
                    return
                }

                guard
                    let data = snapshot?.data(),
                    let addressesData = data["addresses"] as? [[String: Any]]
                else {
                    completion(.success([]))
                    return
                }

                let addresses = addressesData.compactMap {
                    UserAddress.fromDictionary($0)
                }

                completion(.success(addresses))
            }
    }
    
    func deleteAddress(
        uid: String,
        addressId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {

        db.collection("users")
            .document(uid)
            .getDocument { [weak self] snapshot, error in

                if let error {
                    completion(.failure(error))
                    return
                }

                guard
                    let self,
                    let data = snapshot?.data(),
                    let addressData = data["addresses"] as? [[String: Any]]
                else {
                    completion(.failure(NSError()))
                    return
                }

                let updatedAddresses = addressData.filter {
                    ($0["id"] as? String) != addressId
                }

                self.db.collection("users")
                    .document(uid)
                    .updateData([
                        "addresses": updatedAddresses
                    ]) { error in

                        if let error {
                            completion(.failure(error))
                        } else {
                            completion(.success(()))
                        }
                    }
            }
    }
    
    
}

enum UserDBServiceError: Error {
    case invalidUserData
}
