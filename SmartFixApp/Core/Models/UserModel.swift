//
//  UserModel.swift
//  SmartFixApp
//
//  Created by Ahmet Hakan Karaaslan on 29.04.2026.
//

import Foundation

struct UserModel: Codable {
    var uid: String
    var email: String
    var fullName: String
    var role: UserRole
    var isAddressCompleted: Bool
    var addresses: [UserAddress]?
}

enum UserRole: String, Codable {
    case customer
    case technician
}
