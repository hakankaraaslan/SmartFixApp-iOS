//
//  TechnicianTabBarController.swift
//  SmartFixApp
//
//  Created by Ahmet Hakan Karaaslan on 7.04.2026.
//

import UIKit

final class TechnicianTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }

    private func setupTabs() {
        let homeVC = TechnicianHomeViewController()
        homeVC.title = "Home"
        let homeNav = UINavigationController(rootViewController: homeVC)
        homeNav.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)

        let openRequestsVC = OpenRequestsViewController()
        openRequestsVC.title = "Open Requests"
        let openRequestsNav = UINavigationController(rootViewController: openRequestsVC)
        openRequestsNav.tabBarItem = UITabBarItem(title: "Requests", image: UIImage(systemName: "doc.text"), tag: 1)

        let chatsVC = ChatListViewController(role: .technician)
        chatsVC.title = "Chats"
        let chatsNav = UINavigationController(rootViewController: chatsVC)
        chatsNav.tabBarItem = UITabBarItem(title: "Chats", image: UIImage(systemName: "message"), tag: 2)

        viewControllers = [homeNav, openRequestsNav, chatsNav]
        tabBar.tintColor = .systemBlue
    }
}
