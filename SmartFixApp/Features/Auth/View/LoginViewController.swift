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
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

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

                switch result {
                case .success(let uid):
                    FirestoreService.shared.fetchUser(uid: uid) { [weak self] userResult in
                        DispatchQueue.main.async {
                            guard let self else { return }

                            self.setLoading(false)

                            switch userResult {
                            case .success(let user):
                                
                                SessionManager.shared.uid = user.uid
                                SessionManager.shared.role = user.role
                                SessionManager.shared.isAddressCompleted = user.isAddressCompleted
                                
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

                            case .failure(let error):
                                self.showAlert(
                                    title: "User Data Error",
                                    message: error.localizedDescription
                                )
                            }
                        }
                    }

                case .failure(let error):
                    self.setLoading(false)
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
