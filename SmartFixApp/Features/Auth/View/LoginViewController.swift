//
//  ViewController.swift
//  SmartFixApp
//
//  Created by Ahmet Hakan Karaaslan on 4.03.2026.
//

import UIKit
// UIKit iOS uygulamalarında kullanıcı arayüzü oluşturmak için kullanılan temel framework'tür.
// ViewController, UILabel, UIButton gibi tüm görsel bileşenler bu framework içinde yer alır.

final class LoginViewController: UIViewController {
    // LoginViewController uygulamanın giriş ekranını temsil eder.
    // Kullanıcı burada email ve password girerek sisteme login olabilir veya yeni hesap oluşturabilir.

    private let authService = AuthService.shared
    // AuthService singleton instance'ı alınır.
    // Login ve register işlemleri bu servis üzerinden gerçekleştirilir.

    // MARK: - UI Elements
    // Bu bölümde ekranda gösterilecek tüm kullanıcı arayüzü bileşenleri tanımlanır.

    private let titleLabel: UILabel = {
        // titleLabel uygulamanın başlığını gösteren label'dır.
        let label = UILabel()
        label.text = "SmartFix"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private let subtitleLabel: UILabel = {
        // subtitleLabel kullanıcıya kısa bir açıklama gösterir.
        let label = UILabel()
        label.text = "Login or register to continue"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    private let roleSegmentedControl: UISegmentedControl = {
        // Kullanıcının Customer mı yoksa Technician mı olduğunu seçmesini sağlar.
        let control = UISegmentedControl(items: ["Customer", "Technician"])
        control.selectedSegmentIndex = 0
        return control
    }()

    private let emailTextField: UITextField = {
        // Kullanıcının email adresini gireceği metin alanıdır.
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        return textField
    }()

    private let passwordTextField: UITextField = {
        // Kullanıcının şifresini gireceği metin alanıdır.
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        return textField
    }()

    private let loginButton: UIButton = {
        // Kullanıcı mevcut hesabıyla giriş yapmak istediğinde bu butona basar.
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        return button
    }()

    private let registerButton: UIButton = {
        // Kullanıcı yeni hesap oluşturmak istediğinde bu butona basar.
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .systemGray5
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        return button
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        // Yükleme işlemi sırasında kullanıcıya işlem devam ediyor göstermek için kullanılır.
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private lazy var stackView: UIStackView = {
        // StackView tüm UI bileşenlerini dikey olarak düzenlemek için kullanılır.
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel,
            roleSegmentedControl,
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
    // ViewController yaşam döngüsü metotları bu bölümde yer alır.

    override func viewDidLoad() {
        // View yüklendiğinde çalışan ilk metottur.
        // UI kurulumu ve aksiyon tanımlamaları burada yapılır.
        super.viewDidLoad()
        setupUI()
        setupActions()
    }

    // MARK: - Setup
    // UI kurulumu ve buton aksiyonlarının tanımlandığı bölüm.

    private func setupUI() {
        // Ekrandaki UI bileşenlerini view'a ekler ve AutoLayout constraint'lerini kurar.
        view.backgroundColor = .systemBackground
        //title = "Login"

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

    private func setupActions() {
        // Butonlara basıldığında çalışacak aksiyonlar burada tanımlanır.
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
    }

    // MARK: - Actions
    // Kullanıcının butonlara bastığında tetiklenen metotlar.

    @objc private func loginButtonTapped() {
        // Login butonuna basıldığında authentication akışını başlatır.
        handleAuthAction(actionType: "Login")
    }

    @objc private func registerButtonTapped() {
        let registerVC = RegisterViewController()
        navigationController?.pushViewController(registerVC, animated: true)
    }

    // MARK: - Auth Flow
    // Kullanıcı doğrulama (authentication) işlemlerinin yönetildiği bölüm.

    private func handleAuthAction(actionType: String) {
        // Login veya Register işlemlerinin ortak mantığını yöneten fonksiyon.
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

        let completion: (Bool) -> Void = { [weak self] success in
            guard let self = self else { return }

            self.setLoading(false)

            if success {
                let selectedRole: UserRole = self.roleSegmentedControl.selectedSegmentIndex == 0 ? .customer : .technician
                let homeVC = HomeRouter.makeHome(for: selectedRole)
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let sceneDelegate = windowScene.delegate as? SceneDelegate {

                    sceneDelegate.window?.rootViewController = homeVC
                    sceneDelegate.window?.makeKeyAndVisible()
                }
            } else {
                self.showAlert(title: "Authentication Failed", message: "Please try again.")
            }
        }

        if actionType == "Login" {
            authService.login(email: email, password: password, completion: completion)
        } else {
            authService.register(email: email, password: password, completion: completion)
        }
    }

    // MARK: - Helpers
    // Yardımcı fonksiyonlar burada bulunur.

    private func setLoading(_ isLoading: Bool) {
        // Yükleme sırasında UI elemanlarını pasif hale getirir ve loading indicator gösterir.
        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }

        loginButton.isEnabled = !isLoading
        registerButton.isEnabled = !isLoading
        emailTextField.isEnabled = !isLoading
        passwordTextField.isEnabled = !isLoading
        roleSegmentedControl.isEnabled = !isLoading
    }

    private func showAlert(title: String, message: String) {
        // Kullanıcıya hata veya bilgilendirme mesajı göstermek için alert oluşturur.
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
