//
//  AddAddressViewController.swift
//  SmartFixApp
//
//  Created by Oğuzhan Abuhanoğlu on 3.05.2026.
//

import UIKit

final class AddAddressViewController: UIViewController {
    
    private let uid: String
    private let userRole: UserRole

    private let shouldNavigateHomeAfterSave: Bool

    init(uid: String, userRole: UserRole, shouldNavigateHomeAfterSave: Bool = true) {
        self.uid = uid
        self.userRole = userRole
        self.shouldNavigateHomeAfterSave = shouldNavigateHomeAfterSave
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - SUBWIEWS
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "We need your address info to get services from SmartFix technicians near you."
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let cityTextField = AddAddressViewController.makeTextField(
        placeholder: "City"
    )

    private let stateTextField = AddAddressViewController.makeTextField(
        placeholder: "State"
    )

    private let neighborhoodTextField = AddAddressViewController.makeTextField(
        placeholder: "Neighborhood"
    )

    private let streetTextField = AddAddressViewController.makeTextField(
        placeholder: "Street"
    )

    private let buildingNumberTextField = AddAddressViewController.makeTextField(
        placeholder: "Building No"
    )

    private let floorTextField = AddAddressViewController.makeTextField(
        placeholder: "Floor"
    )

    private let doorNumberTextField = AddAddressViewController.makeTextField(
        placeholder: "Door Number"
    )

    private let phoneNumberTextField = AddAddressViewController.makeTextField(
        placeholder: "Phone Number"
    )

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Address", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        return button
    }()

    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            descriptionLabel,
            cityTextField,
            stateTextField,
            neighborhoodTextField,
            streetTextField,
            buildingNumberTextField,
            floorTextField,
            doorNumberTextField,
            phoneNumberTextField,
            saveButton
        ])

        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        addSubviews()
        setupConstraints()
        setupActions()
        setupKeyboardDismissGesture()
    }

    // MARK: - Setup

    private func setup() {
        title = "Add Address"
        navigationItem.largeTitleDisplayMode = .never
        if shouldNavigateHomeAfterSave {
            navigationItem.hidesBackButton = true
        }
        view.backgroundColor = .systemBackground
    }

    private func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(mainStackView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([

            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            // StackView
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),

            // Heights
            cityTextField.heightAnchor.constraint(equalToConstant: 50),
            stateTextField.heightAnchor.constraint(equalToConstant: 50),
            neighborhoodTextField.heightAnchor.constraint(equalToConstant: 50),
            streetTextField.heightAnchor.constraint(equalToConstant: 50),
            buildingNumberTextField.heightAnchor.constraint(equalToConstant: 50),
            floorTextField.heightAnchor.constraint(equalToConstant: 50),
            doorNumberTextField.heightAnchor.constraint(equalToConstant: 50),
            phoneNumberTextField.heightAnchor.constraint(equalToConstant: 50),

            saveButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    private func setupActions() {
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    @objc private func saveButtonTapped() {
        guard
            let city = cityTextField.text, !city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            let state = stateTextField.text, !state.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            let neighborhood = neighborhoodTextField.text, !neighborhood.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            let street = streetTextField.text, !street.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            let buildingNumber = buildingNumberTextField.text, !buildingNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            let floor = floorTextField.text, !floor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            let doorNumber = doorNumberTextField.text, !doorNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            let phoneNumber = phoneNumberTextField.text, !phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            showAlert(title: "Missing Information", message: "Please fill in all address fields.")
            return
        }

        let address = UserAddress(
            id: UUID().uuidString,
            city: city,
            state: state,
            neighborhood: neighborhood,
            street: street,
            buildingNumber: buildingNumber,
            floor: floor,
            doorNumber: doorNumber,
            phoneNumber: phoneNumber
        )

        FirestoreService.shared.saveAddress(uid: uid, address: address) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                switch result {
                case .success:
                    SessionManager.shared.isAddressCompleted = true

                    if self.shouldNavigateHomeAfterSave {
                        let homeVC = HomeRouter.makeHome(for: self.userRole)
                        self.view.window?.rootViewController = homeVC
                        self.view.window?.makeKeyAndVisible()
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                case .failure(let error):
                    self.showAlert(title: "Save Failed", message: error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Helpers
    private static func makeTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .words
        return textField
    }
    
    private func showAlert(title: String, message: String) {
        // Kullanıcıya hata veya bilgilendirme mesajı göstermek için alert oluşturur.
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
