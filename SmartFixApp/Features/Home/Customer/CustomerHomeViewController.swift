//
//  CustomerHomeViewController.swift
//  SmartFixApp
//
//  Created by Ahmet Hakan Karaaslan on 5.03.2026.
//

import UIKit

final class CustomerHomeViewController: UIViewController {
    // CustomerHomeViewController müşteri rolündeki kullanıcıların göreceği ana ekranı temsil eder.
    // Bu ekran genellikle servis talebi oluşturma, geçmiş talepleri görüntüleme gibi işlemleri içerir.

    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome, Customer"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "What would you like to do today?"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let createRequestButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create Request", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        return button
    }()

    private let myRequestsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("My Requests", for: .normal)
        button.backgroundColor = .systemGray5
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        return button
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            welcomeLabel,
            subtitleLabel,
            createRequestButton,
            myRequestsButton
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
        navigationItem.largeTitleDisplayMode = .never
        setupUI()
        setupActions()
    }

    private func setupUI() {
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            createRequestButton.heightAnchor.constraint(equalToConstant: 52),
            myRequestsButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    private func setupActions() {
        createRequestButton.addTarget(self, action: #selector(createRequestButtonTapped), for: .touchUpInside)
        myRequestsButton.addTarget(self, action: #selector(myRequestsButtonTapped), for: .touchUpInside)
    }

    @objc private func createRequestButtonTapped() {
        let createRequestVC = CreateRequestViewController()
        navigationController?.pushViewController(createRequestVC, animated: true)
    }

    @objc private func myRequestsButtonTapped() {
        let myRequestsVC = MyRequestsViewController()
        navigationController?.pushViewController(myRequestsVC, animated: true)
    }

}
