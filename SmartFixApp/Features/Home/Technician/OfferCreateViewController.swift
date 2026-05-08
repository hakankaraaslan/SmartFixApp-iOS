//
//  OfferCreateViewController.swift
//  SmartFixApp
//
//  Created by Ahmet Hakan Karaaslan on 7.04.2026.
//

import UIKit

final class OfferCreateViewController: UIViewController {
    
    private let requestId: String
    private var request: RepairRequestModel?
    private var currentTechnician: UserModel?
    
    // MARK: Init
    init(requestId: String) {
        self.requestId = requestId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: SUBVIEWS
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
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
    
    private let estimatedPriceRangeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .systemGreen
        label.numberOfLines = 0
        return label
    }()
    
    private let deviceLabel: UILabel = {
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
    
    // Address Blok
    private let customerAdressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .red
        label.numberOfLines = 0
        return label
    }()
    
    private let distanceDecriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        label.text = "Customer’s city and district are provided. After submitting your offer and estimated arrival time, you’ll be able to message the customer via Smart Fix and access the full address if your offer is accepted."
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            categoryLabel,
            deviceLabel,
            estimatedPriceRangeLabel,
            descriptionLabel,
            customerAdressLabel,
            distanceDecriptionLabel,
            priceTextField,
            estimatedTimeTextField,
            submitOfferButton,
            activityIndicator
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.setCustomSpacing(50, after: descriptionLabel)
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        fetchInitialData()
        setupKeyboardDismissGesture()
    }
    
    //MARK: Setup
    private func setupUI() {
        title = "Create Offer"
        view.backgroundColor = .systemBackground

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.keyboardDismissMode = .interactive

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),

            priceTextField.heightAnchor.constraint(equalToConstant: 50),
            estimatedTimeTextField.heightAnchor.constraint(equalToConstant: 50),
            submitOfferButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }
    
    // MARK: Configure UI
    private func fetchInitialData() {
        setLoading(true)
        
        RequestService.shared.fetchRequest(requestId: requestId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.setLoading(false)
                
                switch result {
                case .success(let request):
                    self.request = request
                    self.configureData(with: request)
                    
                case .failure(let error):
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func configureData(with request: RepairRequestModel) {
        titleLabel.text = request.title
        categoryLabel.text = "Category: \(request.category)"
        
        let deviceParts = [request.deviceName, request.brand, request.model]
            .compactMap { $0 }
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        if deviceParts.isEmpty {
            deviceLabel.text = "Device: Not specified"
        } else {
            deviceLabel.text = "Device: \(deviceParts.joined(separator: " "))"
        }
        
        let priceRange = PriceEstimator.estimate(
            category: request.category,
            brand: request.brand,
            model: request.model,
            description: request.detailDescription
        )
        
        estimatedPriceRangeLabel.text = "Estimated Price Range: ₺\(priceRange.min) - ₺\(priceRange.max)"
        descriptionLabel.text = request.detailDescription
        
        if let district = request.state {
            customerAdressLabel.text = "\(request.city) / \(district)"
        }
       
    }
    
    
    // MARK: Create Offer
    private func setupActions() {
        submitOfferButton.addTarget(self, action: #selector(submitOfferButtonTapped), for: .touchUpInside)
    }
    
    @objc private func submitOfferButtonTapped() {
        let price = priceTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let estimatedTime = estimatedTimeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        guard !price.isEmpty, !estimatedTime.isEmpty else {
            showAlert(title: "Missing Information", message: "Please enter price and estimated time.")
            return
        }
        
        guard Int(price) != nil else {
            showAlert(title: "Invalid Price", message: "Please enter numeric value.")
            return
        }
        
        guard let request else {
            showAlert(title: "Error", message: "Request not found.")
            return
        }
        
        guard let uid = AuthService.shared.currentUserId else {
            showAlert(title: "Auth Error", message: "User not found.")
            return
        }
        
        setLoading(true)
        
        FirestoreService.shared.fetchUser(uid: uid) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch result {
                case .success(let technician):
                    
                    let offer = OfferModel(
                        id: UUID().uuidString,
                        requestId: request.id,
                        customerId: request.customerId,
                        technicianId: technician.uid,
                        technicianName: technician.fullName,
                        requestTitle: request.title,
                        requestCategory: request.category,
                        requestDeviceName: request.deviceName,
                        requestCity: request.city,
                        price: price,
                        estimatedTime: estimatedTime,
                        status: .pending,
                        createdAt: Date().timeIntervalSince1970
                    )
                    
                    OfferService.shared.createOffer(offer: offer) { result in
                        DispatchQueue.main.async {
                            self.setLoading(false)
                            
                            switch result {
                            case .success:
                                let alert = UIAlertController(
                                       title: "Success",
                                       message: "Offer submitted",
                                       preferredStyle: .alert
                                   )
                                
                                   alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                                       self.navigationController?.popViewController(animated: true)
                                   })

                                   self.present(alert, animated: true)
                                
                            case .failure(let error):
                                self.showAlert(title: "Error", message: error.localizedDescription)
                            }
                        }
                    }
                    
                case .failure(let error):
                    self.setLoading(false)
                    self.showAlert(title: "User Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    
    // MARK: Funcs
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
