//
//  RequestService.swift
//  SmartFixApp
//
//  Created by Oğuzhan Abuhanoğlu on 4.05.2026.
//

import Foundation
import FirebaseFirestore

final class RequestService {
    
    static let shared = RequestService()
    private init() {}
    
    private let db = Firestore.firestore()
    
    // MARK: Create request
    func createRequest(
        request: RepairRequestModel,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        db.collection("requests")
            .document(request.id)
            .setData(request.toDictionary()) { error in
                if let error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
    
    // MARK: Fetch customers own request
    func fetchRequestsForCustomer(
        customerId: String,
        completion: @escaping (Result<[RepairRequestModel], Error>) -> Void
    ) {
        db.collection("requests")
            .whereField("customerId", isEqualTo: customerId)
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                if let error {
                    completion(.failure(error))
                    return
                }
                
                let requests = snapshot?.documents.compactMap { document in
                    RepairRequestModel.fromDictionary(document.data())
                } ?? []
                
                completion(.success(requests))
            }
    }
    
    // MARK: Fetch request for technicians filterin by city
    func fetchRequestsForTechnician(
        cityKey: String,
        completion: @escaping (Result<[RepairRequestModel], Error>) -> Void
    ) {
        db.collection("requests")
            .whereField("cityKey", isEqualTo: cityKey)
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                if let error {
                    completion(.failure(error))
                    return
                }
                
                let requests = snapshot?.documents.compactMap {
                    RepairRequestModel.fromDictionary($0.data())
                } ?? []
                
                completion(.success(requests))
            }
    }
    
    // MARK: Fetch specific request
    func fetchRequest(
        requestId: String,
        completion: @escaping (Result<RepairRequestModel, Error>) -> Void
    ) {
        db.collection("requests")
            .document(requestId)
            .getDocument { snapshot, error in
                if let error {
                    completion(.failure(error))
                    return
                }

                guard var data = snapshot?.data() else {
                    completion(.failure(RequestServiceError.requestNotFound))
                    return
                }

                data["id"] = snapshot?.documentID

                guard let request = RepairRequestModel.fromDictionary(data) else {
                    completion(.failure(RequestServiceError.requestNotFound))
                    return
                }

                completion(.success(request))
            }
    }
    
    
    // MARK: Update request status
    func updateRequestStatus(
        requestId: String,
        status: RequestStatus,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        db.collection("requests")
            .document(requestId)
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
    
    // MARK: Delete my request
    func deleteRequest(
        requestId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        OfferService.shared.deleteOffersForRequest(requestId: requestId) { [weak self] result in
            switch result {
            case .success:
                self?.db.collection("requests")
                    .document(requestId)
                    .delete { error in
                        if let error {
                            completion(.failure(error))
                        } else {
                            completion(.success(()))
                        }
                    }

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: Accept Offer for request
    func acceptOfferForRequest(
        requestId: String,
        offer: OfferModel,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        db.collection("requests")
            .document(requestId)
            .updateData([
                "status": RequestStatus.offerAccepted.rawValue,
                "acceptedOfferId": offer.id,
                "acceptedTechnicianId": offer.technicianId
            ]) { error in
                if let error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
}


enum RequestServiceError: Error {
    case requestNotFound
}
