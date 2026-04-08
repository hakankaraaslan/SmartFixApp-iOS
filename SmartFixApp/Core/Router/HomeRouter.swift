//
//  HomeRouter.swift
//  SmartFixApp
//
//  Created by Ahmet Hakan Karaaslan on 5.03.2026.
//

import UIKit

enum HomeRouter {
    static func makeHome(for role: UserRole) -> UIViewController {
        let rootVC: UIViewController

        switch role {
        case .customer:
            rootVC = CustomerTabBarController()
        case .technician:
            rootVC = TechnicianTabBarController()
        }

        return UINavigationController(rootViewController: rootVC)
    }
}
