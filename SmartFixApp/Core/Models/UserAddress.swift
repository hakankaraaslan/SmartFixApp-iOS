//
//  UserAddress.swift
//  SmartFixApp
//
//  Created by Oğuzhan Abuhanoğlu on 3.05.2026.
//

import Foundation

struct UserAddress: Codable {
    let id: String
    let city: String
    let state: String
    let neighborhood: String
    let street: String
    let buildingNumber: String
    let floor: String
    let doorNumber: String
    let phoneNumber: String
}
