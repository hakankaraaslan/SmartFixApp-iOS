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

    // MARK: Create Chat Room
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
    
    // MARK: Fetch chat rooms
    func fetchChatRooms(
        userId: String,
        role: UserRole,
        completion: @escaping (Result<[ChatRoomModel], Error>) -> Void
    ) {
        let fieldName: String

        switch role {
        case .customer:
            fieldName = "customerId"
        case .technician:
            fieldName = "technicianId"
        }

        db.collection("chatRooms")
            .whereField(fieldName, isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                if let error {
                    completion(.failure(error))
                    return
                }

                let rooms = snapshot?.documents.compactMap {
                    ChatRoomModel.fromDictionary($0.data())
                } ?? []

                completion(.success(rooms))
            }
    }
    
    // MARK: Send Message
    func sendMessage(
        chatRoomId: String,
        message: MessageModel,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let messageRef = db.collection("chatRooms")
            .document(chatRoomId)
            .collection("messages")
            .document(message.id)

        let chatRoomRef = db.collection("chatRooms")
            .document(chatRoomId)

        let batch = db.batch()
        batch.setData(message.toDictionary(), forDocument: messageRef)

        batch.updateData([
            "lastMessage": message.text,
            "updatedAt": message.createdAt
        ], forDocument: chatRoomRef)

        batch.commit { error in
            if let error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    
    // MARK: Listen Messages
    func listenMessages(
        chatRoomId: String,
        completion: @escaping (Result<[MessageModel], Error>) -> Void
    ) -> ListenerRegistration {
        db.collection("chatRooms")
            .document(chatRoomId)
            .collection("messages")
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error {
                    completion(.failure(error))
                    return
                }

                let messages = snapshot?.documents.compactMap {
                    MessageModel.fromDictionary($0.data())
                } ?? []

                completion(.success(messages))
            }
    }
}
