//
//  RequestDetailsViewController.swift
//  SmartFixApp
//
//  Created by Oğuzhan Abuhanoğlu on 4.05.2026.
//

import UIKit

class RequestDetailsViewController: UIViewController {
    
    // MARK: - Init
    private let requestId: String
    private var selectedRepairRequest: RepairRequestModel?
    
    init(requestId: String) {
        self.requestId = requestId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: SUBVIEWS
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

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        fetchRequestDetail()
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
    
    // MARK: DATA
    private func fetchRequestDetail() {
        RequestService.shared.fetchRequest(requestId: requestId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch result {
                case .success(let fetchedRequest):
                    self.selectedRepairRequest = fetchedRequest
                    self.configureData(with: fetchedRequest)

                case .failure(let error):
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    private func configureData(with requestModel: RepairRequestModel) {
        titleLabel.text = requestModel.title
        categoryValueLabel.text = requestModel.category
        statusValueLabel.text = requestModel.status.rawValue
        descriptionValueLabel.text = requestModel.detailDescription
    }


    // MARK: - Actions

    private func setupActions() {
        offersButton.addTarget(self, action: #selector(offersButtonTapped), for: .touchUpInside)
    }
    
    @objc private func offersButtonTapped() {
        guard let selectedRepairRequest else { return }

        let offersVC = OffersForRequestViewController(
            requestId: selectedRepairRequest.id,
            requestTitle: selectedRepairRequest.title
        )

        navigationController?.pushViewController(offersVC, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        // Kullanıcıya hata veya bilgilendirme mesajı göstermek için alert oluşturur.
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
