//
//  TechnicianProfileViewController.swift
//  SmartFixApp
//
//  Created by Oğuzhan Abuhanoğlu on 9.05.2026.
//

import UIKit

final class TechnicianProfileViewController: UIViewController {

    private let headerView: ProfileHeaderView = {
        let view = ProfileHeaderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        layoutConstraints()
        configure()
    }

    private func setup() {
        title = "Profile"
        view.backgroundColor = .systemBackground

        view.addSubview(headerView)
    }

    private func layoutConstraints() {
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            headerView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }

    private func configure() {
        headerView.configure(
            name: SessionManager.shared.currentUser?.fullName ?? "Technician",
            email: SessionManager.shared.currentUser?.email ?? "-"
        )
    }
}
