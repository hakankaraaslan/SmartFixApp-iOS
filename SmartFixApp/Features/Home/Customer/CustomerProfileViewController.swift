//
//  CustomerProfileViewController.swift
//  SmartFixApp
//
//  Created by Oğuzhan Abuhanoğlu on 9.05.2026.
//

import UIKit

final class CustomerProfileViewController: UIViewController {

    private var addresses: [UserAddress] = []

    private let headerView: ProfileHeaderView = {
        let view = ProfileHeaderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let addAddressButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+ Add Address", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        setupTableView()
        layoutConstraints()
        configure()
        fetchAddresses()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAddresses()
    }

    private func setup() {
        title = "Profile"
        view.backgroundColor = .systemBackground
        view.addSubview(headerView)
        view.addSubview(tableView)
    }

    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AddressCell")
        tableView.dataSource = self
        tableView.delegate = self

        addAddressButton.addTarget(
            self,
            action: #selector(addAddressTapped),
            for: .touchUpInside
        )

        let headerContainer = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 60))
        addAddressButton.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.addSubview(addAddressButton)

        NSLayoutConstraint.activate([
            addAddressButton.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 20),
            addAddressButton.trailingAnchor.constraint(lessThanOrEqualTo: headerContainer.trailingAnchor, constant: -20),
            addAddressButton.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor)
        ])

        tableView.tableHeaderView = headerContainer
    }

    private func layoutConstraints() {
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            headerView.heightAnchor.constraint(equalToConstant: 120),

            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func configure() {
        headerView.configure(
            name: SessionManager.shared.currentUser?.fullName ?? "User",
            email: SessionManager.shared.currentUser?.email ?? "-"
        )
    }

    private func fetchAddresses() {
        guard let uid = AuthService.shared.currentUserId else {
            tableView.setEmptyMessage("User session not found.")
            return
        }

        FirestoreService.shared.fetchUserAddresses(uid: uid) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch result {
                case .success(let addresses):
                    self.addresses = addresses
                    self.tableView.reloadData()

                    if addresses.isEmpty {
                        self.tableView.setEmptyMessage("No addresses yet.")
                    } else {
                        self.tableView.restore()
                    }

                case .failure(let error):
                    self.addresses = []
                    self.tableView.reloadData()
                    self.tableView.setEmptyMessage("Could not load addresses.")
                    print("Fetch addresses error:", error.localizedDescription)
                }
            }
        }
    }

    @objc private func addAddressTapped() {
        guard let uid = AuthService.shared.currentUserId,
              let role = SessionManager.shared.role else { return }

        let vc = AddAddressViewController(
            uid: uid,
            userRole: role,
            shouldNavigateHomeAfterSave: false
        )
        navigationController?.pushViewController(vc, animated: true)
    }

    private func deleteAddress(at indexPath: IndexPath) {
        guard let uid = AuthService.shared.currentUserId else { return }

        let address = addresses[indexPath.row]

        FirestoreService.shared.deleteAddress(
            uid: uid,
            addressId: address.id
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch result {
                case .success:
                    self.addresses.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)

                    if self.addresses.isEmpty {
                        self.tableView.setEmptyMessage("No addresses yet.")
                    }

                case .failure(let error):
                    self.showAlert(title: "Delete Failed", message: error.localizedDescription)
                }
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension CustomerProfileViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        addresses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let address = addresses[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddressCell", for: indexPath)

        var content = cell.defaultContentConfiguration()
        content.text = "\(address.city) / \(address.state)"
        content.textProperties.font = .systemFont(ofSize: 17, weight: .semibold)

        content.secondaryText = "\(address.neighborhood), \(address.street), bina no: \(address.buildingNumber), daire: \(address.doorNumber), kat: \(address.floor)"
        content.secondaryTextProperties.font = .systemFont(ofSize: 15, weight: .regular)
        content.secondaryTextProperties.color = .secondaryLabel
        content.secondaryTextProperties.numberOfLines = 0

        cell.contentConfiguration = content
        cell.selectionStyle = .none
        return cell
    }
}

extension CustomerProfileViewController: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            guard let self = self else {
                completion(false)
                return
            }

            self.deleteAddress(at: indexPath)
            completion(true)
        }

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
