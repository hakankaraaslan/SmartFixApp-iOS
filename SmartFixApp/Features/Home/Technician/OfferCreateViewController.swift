//
//  OfferCreateViewController.swift
//  SmartFixApp
//
//  Created by Ahmet Hakan Karaaslan on 7.04.2026.
//

import UIKit

final class OfferCreateViewController: UIViewController {

    private let requestId: String
    private let requestTitle: String
    private let category: String
    private let descriptionText: String

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.numberOfLines = 0
        return label
    }()

    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    private let priceTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Offer Price (e.g. 750)"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        return textField
    }()

    private let estimatedTimeTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Estimated Time (e.g. 2 hours)"
        textField.borderStyle = .roundedRect
        return textField
    }()

    private let submitOfferButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit Offer", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        return button
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            categoryLabel,
            descriptionLabel,
            priceTextField,
            estimatedTimeTextField,
            submitOfferButton,
            activityIndicator
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    init(requestId: String, requestTitle: String, category: String, descriptionText: String) {
        self.requestId = requestId
        self.requestTitle = requestTitle
        self.category = category
        self.descriptionText = descriptionText
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureData()
        setupActions()
    }

    private func setupUI() {
        title = "Create Offer"
        view.backgroundColor = .systemBackground

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            priceTextField.heightAnchor.constraint(equalToConstant: 50),
            estimatedTimeTextField.heightAnchor.constraint(equalToConstant: 50),
            submitOfferButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    private func configureData() {
        titleLabel.text = requestTitle
        categoryLabel.text = "Category: \(category)"
        descriptionLabel.text = descriptionText
    }

    private func setupActions() {
        submitOfferButton.addTarget(self, action: #selector(submitOfferButtonTapped), for: .touchUpInside)
    }

    @objc private func submitOfferButtonTapped() {
        let price = (priceTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let estimatedTime = (estimatedTimeTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        guard !price.isEmpty, !estimatedTime.isEmpty else {
            showAlert(title: "Missing Information", message: "Please enter price and estimated time.")
            return
        }

        guard Int(price) != nil else {
            showAlert(title: "Invalid Price", message: "Please enter a numeric price.")
            return
        }

        setLoading(true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
            guard let self = self else { return }
            self.setLoading(false)

            let createdOffer = Offer(
                id: UUID().uuidString,
                requestId: self.requestId,
                technicianName: "Current Technician",
                price: price,
                estimatedTime: estimatedTime
            )
            MockDataProvider.shared.addOffer(createdOffer)

            let alert = UIAlertController(
                title: "Offer Submitted",
                message: "Offer for request ID: \(createdOffer.requestId)\nPrice: ₺\(createdOffer.price)\nEstimated Time: \(createdOffer.estimatedTime)",
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self.navigationController?.popToViewController(
                    self.navigationController?.viewControllers.first(where: { $0 is OpenRequestsViewController }) ?? self,
                    animated: true
                )
            })

            self.present(alert, animated: true)
        }
    }

    private func setLoading(_ isLoading: Bool) {
        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }

        priceTextField.isEnabled = !isLoading
        estimatedTimeTextField.isEnabled = !isLoading
        submitOfferButton.isEnabled = !isLoading
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
