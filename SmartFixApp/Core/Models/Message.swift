//
//  Message.swift
//  SmartFixApp
//
//  Created by Ahmet Hakan Karaaslan on 8.04.2026.
//

import Foundation

struct MessageModel: Codable, Sendable {
    let id: String
    let chatRoomId: String
    let senderId: String
    let senderRole: UserRole
    let text: String
    let createdAt: TimeInterval
}
