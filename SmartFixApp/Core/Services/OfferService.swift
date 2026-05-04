//
//  OfferService.swift
//  SmartFixApp
//
//  Created by Oğuzhan Abuhanoğlu on 4.05.2026.
//

import Foundation
import FirebaseFirestore

final class OfferService {

    static let shared = OfferService()
    private init() {}

    private let db = Firestore.firestore()

    func createOffer(
        offer: OfferModel,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        db.collection("offers")
            .document(offer.id)
            .setData(offer.toDictionary()) { error in
                if let error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }

    func fetchOffersForTechnician(
        technicianId: String,
        status: OfferStatus,
        completion: @escaping (Result<[OfferModel], Error>) -> Void
    ) {
        db.collection("offers")
            .whereField("technicianId", isEqualTo: technicianId)
            .whereField("status", isEqualTo: status.rawValue)
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                if let error {
                    completion(.failure(error))
                    return
                }

                let offers = snapshot?.documents.compactMap {
                    OfferModel.fromDictionary($0.data())
                } ?? []

                completion(.success(offers))
            }
    }
    
    func fetchOffersForRequest(
        requestId: String,
        completion: @escaping (Result<[OfferModel], Error>) -> Void
    ) {
        db.collection("offers")
            .whereField("requestId", isEqualTo: requestId)
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                if let error {
                    completion(.failure(error))
                    return
                }

                let offers = snapshot?.documents.compactMap {
                    OfferModel.fromDictionary($0.data())
                } ?? []

                completion(.success(offers))
            }
    }
    
    func fetchAllOffersForTechnician(
        technicianId: String,
        completion: @escaping (Result<[OfferModel], Error>) -> Void
    ) {
        db.collection("offers")
            .whereField("technicianId", isEqualTo: technicianId)
            .getDocuments { snapshot, error in
                if let error {
                    completion(.failure(error))
                    return
                }

                let offers = snapshot?.documents.compactMap {
                    OfferModel.fromDictionary($0.data())
                } ?? []

                completion(.success(offers))
            }
    }
    
    func deleteOffersForRequest(
        requestId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        db.collection("offers")
            .whereField("requestId", isEqualTo: requestId)
            .getDocuments { snapshot, error in
                if let error {
                    completion(.failure(error))
                    return
                }

                let batch = self.db.batch()

                snapshot?.documents.forEach { document in
                    batch.deleteDocument(document.reference)
                }

                batch.commit { error in
                    if let error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            }
    }
}
