//
//  UserModel.swift
//  SmartFixApp
//
//  Created by Ahmet Hakan Karaaslan on 29.04.2026.
//

import Foundation

struct UserModel: Codable {
    var id: Int
    var userType: userTypes
    var name: String
    var email: String
    var password: String
    var phone: String
    var address: String
    var isActive: Bool
   
}

enum userTypes : Codable {
    case member
    case tecnician
}


