//
//  ViewController.swift
//  SmartFixApp
//
//  Created by Ahmet Hakan Karaaslan on 4.03.2026.
//

import UIKit

final class LoginViewController: UIViewController {

    // MARK: - UI

    private let roleControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Customer", "Technician"])
        sc.selectedSegmentIndex = 0
        return sc
    }()

    private let emailField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.borderStyle = .roundedRect
        return tf
    }()

    private let passwordField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.borderStyle = .roundedRect
        return tf
    }()

    private let loginButton: UIButton = {
        var cfg = UIButton.Configuration.filled()
        cfg.title = "Login"
        return UIButton(configuration: cfg)
    }()

    private let registerButton: UIButton = {
        var cfg = UIButton.Configuration.tinted()
        cfg.title = "Register"
        return UIButton(configuration: cfg)
    }()

    private let activity = UIActivityIndicatorView(style: .medium)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "SmartFix"
        view.backgroundColor = .systemBackground
        setupLayout()
        bindActions()
    }

    // MARK: - Helpers

    private func setupLayout() {
        activity.hidesWhenStopped = true

        let stack = UIStackView(arrangedSubviews: [
            roleControl,
            emailField,
            passwordField,
            loginButton,
            registerButton,
            activity
        ])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        [emailField, passwordField, loginButton, registerButton].forEach {
            $0.heightAnchor.constraint(equalToConstant: 44).isActive = true
        }
    }

    private func bindActions() {
        loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
    }

    private var selectedRole: UserRole {
        roleControl.selectedSegmentIndex == 0 ? .customer : .technician
    }

    private func setLoading(_ isLoading: Bool) {
        if isLoading { activity.startAnimating() } else { activity.stopAnimating() }
        [roleControl, emailField, passwordField, loginButton, registerButton]
            .forEach { $0.isUserInteractionEnabled = !isLoading }
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Actions

    @objc private func didTapLogin() {
        // Sprint 1: test amaçlı minimal validation
        let email = (emailField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let pass  = (passwordField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        guard !email.isEmpty, !pass.isEmpty else {
            showError("Email ve şifre gir.")
            return
        }

        // Sprint 1: şimdilik “login başarılı” kabul edip role’a göre home’a git
        setLoading(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self else { return }
            self.setLoading(false)

            let home = HomeRouter.makeHome(for: self.selectedRole)
            self.navigationController?.setViewControllers([home], animated: true)
        }
    }

    @objc private func didTapRegister() {
        // Sprint 1: Register şimdilik aynı şekilde home’a götürsün (Firebase gelince ayrıştıracağız)
        setLoading(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self else { return }
            self.setLoading(false)

            let home = HomeRouter.makeHome(for: self.selectedRole)
            self.navigationController?.setViewControllers([home], animated: true)
        }
    }
}
