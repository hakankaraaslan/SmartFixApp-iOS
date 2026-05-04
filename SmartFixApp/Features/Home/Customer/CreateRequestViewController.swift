//
//  CreateRequestViewController.swift
//  SmartFixApp
//
//  Created by Ahmet Hakan Karaaslan on 7.04.2026.
//

import UIKit

final class CreateRequestViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // MARK: - UI Elements

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create Repair Request"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Describe the problem and add at least one photo."
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.text = "Category"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()

    private let categorySegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["White Goods", "Electrical", "Plumbing"])
        control.selectedSegmentIndex = 0
        return control
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Problem Description"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()

    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.layer.cornerRadius = 12
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        return textView
    }()

    
    private let deviceLabel: UILabel = {
        let label = UILabel()
        label.text = "Device"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private let deviceTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Device (e.g. Fridge)"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .words
        textField.autocorrectionType = .no
        return textField
    }()
    
    
    private let brandLabel: UILabel = {
        let label = UILabel()
        label.text = "Brand"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private let brandTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Brand (e.g. Samsung)"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .words
        textField.autocorrectionType = .no
        return textField
    }()

    private let modelLabel: UILabel = {
        let label = UILabel()
        label.text = "Model"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()

    private let modelTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Model (e.g. Odyssey G5)"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .words
        textField.autocorrectionType = .no
        return textField
    }()

    private let selectedPhotoLabel: UILabel = {
        let label = UILabel()
        label.text = "No photo selected"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let selectedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = .systemGray6
        imageView.isHidden = true
        return imageView
    }()

    private let addPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Photo", for: .normal)
        button.backgroundColor = .systemGray5
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        return button
    }()

    private let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit Request", for: .normal)
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
            subtitleLabel,
            categoryLabel,
            categorySegmentedControl,
            descriptionLabel,
            descriptionTextView,
            deviceLabel,
            deviceTextField,
            brandLabel,
            brandTextField,
            modelLabel,
            modelTextField,
            selectedPhotoLabel,
            selectedImageView,
            addPhotoButton,
            submitButton,
            activityIndicator
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Properties

    private var selectedImage: UIImage?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }

    // MARK: - Setup

    private func setupUI() {
        title = "Create Request"
        view.backgroundColor = .systemBackground
        scrollView.keyboardDismissMode = .interactive

        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stackView)

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

            descriptionTextView.heightAnchor.constraint(equalToConstant: 140),
            deviceTextField.heightAnchor.constraint(equalToConstant: 44),
            brandTextField.heightAnchor.constraint(equalToConstant: 44),
            modelTextField.heightAnchor.constraint(equalToConstant: 44),
            selectedImageView.heightAnchor.constraint(equalToConstant: 180),
            addPhotoButton.heightAnchor.constraint(equalToConstant: 52),
            submitButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    private func setupActions() {
        addPhotoButton.addTarget(self, action: #selector(addPhotoButtonTapped), for: .touchUpInside)
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
    }

    // MARK: - Actions

    @objc private func addPhotoButtonTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

    @objc private func submitButtonTapped() {
        handleSubmit()
    }

    // MARK: - Form Logic

    private func handleSubmit() {
        let descriptionText = descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let deviceText = deviceTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let brandText = brandTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let modelText = modelTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !descriptionText.isEmpty else {
            showAlert(title: "Missing Description", message: "Please describe the problem.")
            return
        }

        guard !deviceText.isEmpty else {
            showAlert(title: "Missing Device", message: "Please enter the device name.")
            return
        }

        guard selectedImage != nil else {
            showAlert(title: "Photo Required", message: "Please add at least one photo.")
            return
        }

        guard let uid = AuthService.shared.currentUserId else {
            showAlert(title: "Auth Error", message: "User session not found.")
            return
        }

        setLoading(true)

        FirestoreService.shared.fetchUser(uid: uid) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                switch result {
                case .success(let user):

                    guard let city = user.address?.city, !city.isEmpty else {
                        self.setLoading(false)
                        self.showAlert(title: "Address Error", message: "User city not found.")
                        return
                    }

                    let category = self.selectedCategoryTitle()
                    let requestId = UUID().uuidString
                    let generatedTitle = "\(deviceText) - \(String(descriptionText.prefix(30)))"

                    let request = RepairRequestModel(
                        id: requestId,
                        customerId: user.uid,
                        customerName: user.fullName,
                        category: category,
                        deviceName: deviceText,
                        title: generatedTitle,
                        detailDescription: descriptionText,
                        brand: brandText.isEmpty ? nil : brandText,
                        model: modelText.isEmpty ? nil : modelText,
                        city: city,
                        state: user.address?.state,
                        customerAddress: user.address,
                        status: .open,
                        acceptedOfferId: nil,
                        acceptedTechnicianId: nil
                    )

                    RequestService.shared.createRequest(request: request) { [weak self] createResult in
                        DispatchQueue.main.async {
                            guard let self else { return }
                            self.setLoading(false)

                            switch createResult {
                            case .success:
                                let alert = UIAlertController(
                                    title: "Request Created",
                                    message: "Your repair request has been created successfully.",
                                    preferredStyle: .alert
                                )

                                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                                    self.navigationController?.popViewController(animated: true)
                                })

                                self.present(alert, animated: true)

                            case .failure(let error):
                                self.showAlert(title: "Create Failed", message: error.localizedDescription)
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

    private func selectedCategoryTitle() -> String {
        switch categorySegmentedControl.selectedSegmentIndex {
        case 0: return "White Goods"
        case 1: return "Electrical"
        case 2: return "Plumbing"
        default: return "White Goods"
        }
    }

    private func setLoading(_ isLoading: Bool) {
        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }

        categorySegmentedControl.isEnabled = !isLoading
        descriptionTextView.isEditable = !isLoading
        brandTextField.isEnabled = !isLoading
        modelTextField.isEnabled = !isLoading
        addPhotoButton.isEnabled = !isLoading
        submitButton.isEnabled = !isLoading
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - UIImagePickerControllerDelegate

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            selectedImage = image
            selectedImageView.image = image
            selectedImageView.isHidden = false
            selectedPhotoLabel.text = "1 photo selected"
        }

        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
