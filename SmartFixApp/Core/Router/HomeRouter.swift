//
//  HomeRouter.swift
//  SmartFixApp
//
//  Created by Ahmet Hakan Karaaslan on 5.03.2026.
//

import UIKit

enum HomeRouter {
    static func makeHome(for role: UserRole) -> UIViewController {
        switch role {
        case .customer:
            return CustomerHomeViewController()
        case .technician:
            return TechnicianHomeViewController()
        }
    }
}
