//
//  Request.swift
//  SmartFixApp
//
//  Created by Ahmet Hakan Karaaslan on 8.04.2026.
//

import Foundation

struct Request {
    let id: String
    let category: String
    let title: String
    let detailDescription: String
    let brand: String?
    let model: String?
    let status: RequestStatus
}
