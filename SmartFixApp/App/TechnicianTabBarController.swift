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
        AuthService.shared.logout { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                switch result {

                case .success:

                    let loginVC = LoginViewController()

                    let nav = UINavigationController(rootViewController: loginVC)
                    nav.navigationBar.prefersLargeTitles = true

                    self.view.window?.rootViewController = nav
                    self.view.window?.makeKeyAndVisible()

                case .failure(let error):

                    let alert = UIAlertController(
                        title: "Logout Failed",
                        message: error.localizedDescription,
                        preferredStyle: .alert
                    )

                    alert.addAction(UIAlertAction(title: "OK", style: .default))

                    self.present(alert, animated: true)
                }
            }
        }
    }

    private func setupTabs() {
        let homeVC = TechnicianHomeViewController()
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
        navigationItem.largeTitleDisplayMode = .never
    }
}
