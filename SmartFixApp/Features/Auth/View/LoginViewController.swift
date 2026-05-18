//
//  ViewController.swift
//  SmartFixApp
//
//  Created by Ahmet Hakan Karaaslan on 4.03.2026.
//

import UIKit

final class LoginViewController: UIViewController {

    private let authService = AuthService.shared
    
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "SmartFix"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Login or register to continue"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        return textField
    }()

    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        return textField
    }()

    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        return button
    }()

    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .systemGray5
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 10
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
            emailTextField,
            passwordTextField,
            loginButton,
            registerButton,
            activityIndicator
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        setupKeyboardDismissGesture()
        setupKeyboardObservers(for: scrollView)
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(stackView)

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
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
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 100),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            registerButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    
    // MARK: - Actions
    private func setupActions() {
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
    }

    @objc private func loginButtonTapped() {
        handleLogin()
    }

    @objc private func registerButtonTapped() {
        let registerVC = RegisterViewController()
        navigationController?.pushViewController(registerVC, animated: true)
    }

    // MARK: - Auth Flow
    private func handleLogin() {
        guard let email = emailTextField.text, !email.trimmingCharacters(in: .whitespaces).isEmpty,
              let password = passwordTextField.text, !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            showAlert(title: "Missing Information", message: "Please enter email and password.")
            return
        }

        guard email.contains("@"), email.contains(".") else {
            showAlert(title: "Invalid Email", message: "Please enter a valid email address.")
            return
        }

        guard password.count >= 6 else {
            showAlert(title: "Weak Password", message: "Password must be at least 6 characters.")
            return
        }

        setLoading(true)

        authService.login(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                self.setLoading(false)

                switch result {
                case .success(let user):

                    if user.isAddressCompleted {
                        let homeVC = HomeRouter.makeHome(for: user.role)
                        self.view.window?.rootViewController = homeVC
                        self.view.window?.makeKeyAndVisible()
                    } else {
                        let addAddressVC = AddAddressViewController(
                            uid: user.uid,
                            userRole: user.role
                        )
                        self.navigationController?.pushViewController(addAddressVC, animated: true)
                    }

                case .failure(_):
                    self.showAlert(
                        title: "Login Failed",
                        message: "Email or password is incorrect."
                    )
                }
            }
        }
    }

    // MARK: - Helpers
    private func setLoading(_ isLoading: Bool) {
        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }

        loginButton.isEnabled = !isLoading
        registerButton.isEnabled = !isLoading
        emailTextField.isEnabled = !isLoading
        passwordTextField.isEnabled = !isLoading
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
