//
//  RequestDetailViewController.swift
//  SmartFixApp
//
//  Created by Ahmet Hakan Karaaslan on 7.04.2026.
//

import UIKit

final class RequestDetailViewController: UIViewController {

    // MARK: - Model

    struct RequestDetail {
        let category: String
        let problemTitle: String
        let description: String
        let status: String
    }

    // MARK: - Properties

    private let request: RequestDetail

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.numberOfLines = 0
        return label
    }()

    private let categoryTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Category"
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .secondaryLabel
        return label
    }()

    private let categoryValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    private let statusTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Status"
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .secondaryLabel
        return label
    }()

    private let statusValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    private let descriptionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Problem Description"
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .secondaryLabel
        return label
    }()

    private let descriptionValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    private let offersButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("View Offers", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        return button
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            categoryTitleLabel,
            categoryValueLabel,
            statusTitleLabel,
            statusValueLabel,
            descriptionTitleLabel,
            descriptionValueLabel,
            offersButton
        ])
        stack.axis = .vertical
        stack.spacing = 14
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Init

    init(request: RequestDetail) {
        self.request = request
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureData()
        setupActions()
    }

    // MARK: - Setup

    private func setupUI() {
        title = "Request Detail"
        view.backgroundColor = .systemBackground

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            offersButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    private func configureData() {
        titleLabel.text = request.problemTitle
        categoryValueLabel.text = request.category
        statusValueLabel.text = request.status
        descriptionValueLabel.text = request.description
    }

    private func setupActions() {
        offersButton.addTarget(self, action: #selector(offersButtonTapped), for: .touchUpInside)
    }

    // MARK: - Actions

    @objc private func offersButtonTapped() {
        let offersVC = OffersForRequestViewController(requestTitle: request.problemTitle)
        navigationController?.pushViewController(offersVC, animated: true)
    }
}
