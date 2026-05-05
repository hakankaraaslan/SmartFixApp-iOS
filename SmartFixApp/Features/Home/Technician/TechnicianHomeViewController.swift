//
//  TechnicianHomeViewController.swift
//  SmartFixApp
//
//  Created by Ahmet Hakan Karaaslan on 5.03.2026.
//

import UIKit

final class TechnicianHomeViewController: UIViewController {

    private let sessionManager = SessionManager.shared
    
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "View open repair requests and send your offer."
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let openRequestsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Open Requests", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        return button
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            welcomeLabel,
            subtitleLabel,
            openRequestsButton
        ])
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        configureUser()
        setupActions()
    }

    private func setupUI() {
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            openRequestsButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    private func configureUser() {
        let name = sessionManager.currentUser?.fullName ?? "User"
        welcomeLabel.text = "Welcome, \(name)"

    }
    
    private func setupActions() {
        openRequestsButton.addTarget(self, action: #selector(openRequestsButtonTapped), for: .touchUpInside)
    }

    @objc private func openRequestsButtonTapped() {
        let openRequestsVC = OpenRequestsViewController()
        navigationController?.pushViewController(openRequestsVC, animated: true)
    }
}
