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

    func createRequest(
        request: RepairRequestModel,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let data: [String: Any] = [
            "id": request.id,
            "customerId": request.customerId,
            "customerName": request.customerName,

            "category": request.category,
            "deviceName": request.deviceName,
            "title": request.title,
            "detailDescription": request.detailDescription,
            "brand": request.brand as Any,
            "model": request.model as Any,

            "city": request.city,
            "state": request.state as Any,
            "customerAddress": request.customerAddress?.toDictionary() as Any,

            "status": request.status.rawValue,

            "acceptedOfferId": request.acceptedOfferId as Any,
            "acceptedTechnicianId": request.acceptedTechnicianId as Any,

            "createdAt": Timestamp(date: Date())
        ]

        db.collection("requests")
            .document(request.id)
            .setData(data) { error in
                if let error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
}
