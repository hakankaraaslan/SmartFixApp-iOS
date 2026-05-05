//
//  AcceptedRequestViewController.swift
//  SmartFixApp
//
//  Created by Oğuzhan Abuhanoğlu on 5.05.2026.
//

import UIKit

final class AcceptedRequestDetailViewController: UIViewController {

    private let requestId: String
    private var selectedRepairRequest: RepairRequestModel?

    init(requestId: String) {
        self.requestId = requestId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.numberOfLines = 0
        return label
    }()

    private let categoryTitleLabel = AcceptedRequestDetailViewController.makeTitleLabel("Category")
    private let categoryValueLabel = AcceptedRequestDetailViewController.makeValueLabel()

    private let statusTitleLabel = AcceptedRequestDetailViewController.makeTitleLabel("Status")
    private let statusValueLabel = AcceptedRequestDetailViewController.makeValueLabel()

    private let descriptionTitleLabel = AcceptedRequestDetailViewController.makeTitleLabel("Problem Description")
    private let descriptionValueLabel = AcceptedRequestDetailViewController.makeValueLabel()

    private let completeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Mark as Completed", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        return button
    }()

    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel Request", for: .normal)
        button.backgroundColor = .systemRed
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
            completeButton,
            cancelButton
        ])
        stack.axis = .vertical
        stack.spacing = 23
        stack.setCustomSpacing(6, after: categoryTitleLabel)
        stack.setCustomSpacing(6, after: statusTitleLabel)
        stack.setCustomSpacing(6, after: descriptionTitleLabel)
        stack.setCustomSpacing(6, after: completeButton)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        fetchRequestDetail()
    }

    private func setupUI() {
        title = "Accepted Request"
        view.backgroundColor = .systemBackground

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            completeButton.heightAnchor.constraint(equalToConstant: 52),
            cancelButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    private func setupActions() {
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }

    private func fetchRequestDetail() {
        RequestService.shared.fetchRequest(requestId: requestId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                switch result {
                case .success(let request):
                    self.selectedRepairRequest = request
                    self.configureData(with: request)

                case .failure(let error):
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    private func configureData(with request: RepairRequestModel) {
        titleLabel.text = request.title
        categoryValueLabel.text = request.category
        statusValueLabel.text = request.status.rawValue
        descriptionValueLabel.text = request.detailDescription
    }

    @objc private func completeButtonTapped() {
        updateRequestStatus(.completed)
    }

    @objc private func cancelButtonTapped() {
        let alert = UIAlertController(
            title: "Cancel Request",
            message: "Are you sure you want to cancel this request?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes, Cancel", style: .destructive) { [weak self] _ in
            self?.updateRequestStatus(.cancelled)
        })

        present(alert, animated: true)
    }

    private func updateRequestStatus(_ status: RequestStatus) {
        guard let selectedRepairRequest else { return }

        RequestService.shared.updateRequestStatus(
            requestId: selectedRepairRequest.id,
            status: status
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                switch result {
                case .success:
                    self.updateAcceptedOfferStatus(for: selectedRepairRequest, requestStatus: status)

                case .failure(let error):
                    self.showAlert(title: "Update Failed", message: error.localizedDescription)
                }
            }
        }
    }

    private func updateAcceptedOfferStatus(
        for request: RepairRequestModel,
        requestStatus: RequestStatus
    ) {
        guard let acceptedOfferId = request.acceptedOfferId else {
            navigationController?.popViewController(animated: true)
            return
        }

        let offerStatus: OfferStatus

        switch requestStatus {
        case .completed:
            offerStatus = .completed
        case .cancelled:
            offerStatus = .cancelled
        default:
            navigationController?.popViewController(animated: true)
            return
        }

        OfferService.shared.updateOfferStatus(
            offerId: acceptedOfferId,
            status: offerStatus
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                switch result {
                case .success:
                    self.navigationController?.popViewController(animated: true)

                case .failure(let error):
                    self.showAlert(title: "Offer Update Failed", message: error.localizedDescription)
                }
            }
        }
    }
    private static func makeTitleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .secondaryLabel
        return label
    }

    private static func makeValueLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.numberOfLines = 0
        return label
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
