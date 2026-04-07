//
//  CustomerTabBarController.swift
//  SmartFixApp
//
//  Created by Ahmet Hakan Karaaslan on 7.04.2026.
//

import UIKit

final class CustomerTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }

    private func setupTabs() {
        let homeVC = CustomerHomeViewController()
        homeVC.title = "Home"
        let homeNav = UINavigationController(rootViewController: homeVC)
        homeNav.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)

        let myRequestsVC = MyRequestsViewController()
        myRequestsVC.title = "My Requests"
        let myRequestsNav = UINavigationController(rootViewController: myRequestsVC)
        myRequestsNav.tabBarItem = UITabBarItem(title: "Requests", image: UIImage(systemName: "doc.text"), tag: 1)

        let chatsVC = ChatListViewController(role: .customer)
        chatsVC.title = "Chats"
        let chatsNav = UINavigationController(rootViewController: chatsVC)
        chatsNav.tabBarItem = UITabBarItem(title: "Chats", image: UIImage(systemName: "message"), tag: 2)

        viewControllers = [homeNav, myRequestsNav, chatsNav]
        tabBar.tintColor = .systemBlue
    }
}
