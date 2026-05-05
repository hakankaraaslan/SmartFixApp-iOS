//
//  ChatRoom.swift
//  SmartFixApp
//
//  Created by Ahmet Hakan Karaaslan on 8.04.2026.
//

import Foundation

struct ChatRoomModel: Codable, Sendable {
    let id: String
    let requestId: String
    let requestTitle: String

    let customerId: String
    let customerName: String

    let technicianId: String
    let technicianName: String

    let lastMessage: String
    let createdAt: TimeInterval
}
