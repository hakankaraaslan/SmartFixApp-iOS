////
////  MockDataProvider.swift
////  SmartFixApp
////
////  Created by Ahmet Hakan Karaaslan on 8.04.2026.
////
//
//import Foundation
//
//final class MockDataProvider {
//
//    static let shared = MockDataProvider()
//
//    private init() {}
//
//    // MARK: - Requests
//
//    var customerRequests: [Request] = [
//        Request(
//            id: "req-1",
//            category: "White Goods",
//            title: "Refrigerator is not cooling",
//            detailDescription: "The refrigerator stopped cooling yesterday evening.",
//            brand: "Samsung",
//            model: "Refrigerator X100",
//            status: .open
//        ),
//        Request(
//            id: "req-2",
//            category: "Plumbing",
//            title: "Kitchen sink leakage",
//            detailDescription: "Water is leaking from under the sink cabinet.",
//            brand: "Samsung",
//            model: "Refrigerator X100",
//            status: .accepted
//        )
//    ]
//
//    var openRequests: [Request] = [
//        Request(
//            id: "req-1",
//            category: "White Goods",
//            title: "Refrigerator is not cooling",
//            detailDescription: "The refrigerator stopped cooling yesterday evening.",
//            brand: nil,
//            model: nil,
//            status: .open
//        ),
//        Request(
//            id: "req-3",
//            category: "Electrical",
//            title: "Power outlet is not working",
//            detailDescription: "One outlet in the living room has no power.",
//            brand: nil,
//            model: nil,
//            status: .open
//        ),
//        Request(
//            id: "req-2",
//            category: "Plumbing",
//            title: "Kitchen sink leakage",
//            detailDescription: "Water is leaking from under the sink cabinet.",
//            brand: nil,
//            model: nil,
//            status: .accepted
//        )
//    ]
//
//    // MARK: - Offers
//
//    var offers: [Offer] = [
//        Offer(
//            id: "offer-1",
//            requestId: "req-2",
//            technicianName: "Ahmet Repair Service",
//            price: "750",
//            estimatedTime: "2 hours"
//        ),
//        Offer(
//            id: "offer-2",
//            requestId: "req-2",
//            technicianName: "Teknik Destek Pro",
//            price: "680",
//            estimatedTime: "3 hours"
//        ),
//        Offer(
//            id: "offer-3",
//            requestId: "req-2",
//            technicianName: "Hızlı Usta",
//            price: "820",
//            estimatedTime: "1 hour"
//        )
//    ]
//
//    // MARK: - Chat Rooms
//
//    var customerChatRooms: [ChatRoom] = [
//        ChatRoom(
//            id: "chat-1",
//            requestId: "req-1",
//            participantName: "Ahmet Repair Service",
//            requestTitle: "Refrigerator is not cooling",
//            lastMessage: "I can come tomorrow morning."
//        ),
//        ChatRoom(
//            id: "chat-2",
//            requestId: "req-2",
//            participantName: "Teknik Destek Pro",
//            requestTitle: "Kitchen sink leakage",
//            lastMessage: "Can you send one more photo?"
//        )
//    ]
//
//    var technicianChatRooms: [ChatRoom] = [
//        ChatRoom(
//            id: "chat-3",
//            requestId: "req-3",
//            participantName: "Mehmet Yılmaz",
//            requestTitle: "Power outlet is not working",
//            lastMessage: "Can you come this evening?"
//        ),
//        ChatRoom(
//            id: "chat-4",
//            requestId: "req-2",
//            participantName: "Ayşe Demir",
//            requestTitle: "Kitchen sink leakage",
//            lastMessage: "The leak is getting worse."
//        )
//    ]
//
//    // MARK: - Messages
//
//    private var messagesByChatRoomId: [String: [Message]] = [
//        "chat-1": [
//            Message(id: UUID().uuidString, text: "Hello, I reviewed your request.", senderRole: .technician),
//            Message(id: UUID().uuidString, text: "Thank you. When are you available?", senderRole: .customer),
//            Message(id: UUID().uuidString, text: "I can come tomorrow morning.", senderRole: .technician)
//        ],
//        "chat-2": [
//            Message(id: UUID().uuidString, text: "Can you send one more photo?", senderRole: .technician)
//        ],
//        "chat-3": [
//            Message(id: UUID().uuidString, text: "Can you come this evening?", senderRole: .customer)
//        ],
//        "chat-4": [
//            Message(id: UUID().uuidString, text: "The leak is getting worse.", senderRole: .customer)
//        ]
//    ]
//
//    // MARK: - Methods
//
//    func messages(for chatRoomId: String) -> [Message] {
//        messagesByChatRoomId[chatRoomId] ?? []
//    }
//
//    func addMessage(_ message: Message, for chatRoomId: String) {
//        if messagesByChatRoomId[chatRoomId] != nil {
//            messagesByChatRoomId[chatRoomId]?.append(message)
//        } else {
//            messagesByChatRoomId[chatRoomId] = [message]
//        }
//    }
//
//    func offers(for requestId: String) -> [Offer] {
//        offers.filter { $0.requestId == requestId }
//    }
//
//    func addOffer(_ offer: Offer) {
//        offers.append(offer)
//    }
//}
