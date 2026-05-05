//
//  ChatService.swift
//  SmartFixApp
//
//  Created by Oğuzhan Abuhanoğlu on 5.05.2026.
//

import Foundation
import FirebaseFirestore

final class ChatService {

    static let shared = ChatService()
    private init() {}

    private let db = Firestore.firestore()

    func createChatRoom(
        chatRoom: ChatRoomModel,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        db.collection("chatRooms")
            .document(chatRoom.id)
            .setData(chatRoom.toDictionary()) { error in
                if let error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
}
