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

    // MARK: Create offer for request
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

    // MARK: Fetch technician offers (filtering by status)
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
    
    // MARK: Fetch offers for sepecific request for customers
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
    
    // MARK: Fetch technicians all offers
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
    
    // MARK: Delete offer for request
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
    
    // MARK: Update offer status
    func updateOfferStatus(
        offerId: String,
        status: OfferStatus,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        db.collection("offers")
            .document(offerId)
            .updateData([
                "status": status.rawValue
            ]) { error in
                if let error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
    
    // MARK: Reject other offers
    func rejectOtherOffers(
        requestId: String,
        acceptedOfferId: String,
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

                snapshot?.documents.forEach { doc in
                    if doc.documentID != acceptedOfferId {
                        batch.updateData(
                            ["status": OfferStatus.rejected.rawValue],
                            forDocument: doc.reference
                        )
                    }
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
