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
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Logout",
            style: .plain,
            target: self,
            action: #selector(logoutTapped)
        )
    }

    @objc private func logoutTapped() {
        let loginVC = LoginViewController()
        let nav = UINavigationController(rootViewController: loginVC)

        if let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = nav
            sceneDelegate.window?.makeKeyAndVisible()
        }
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
