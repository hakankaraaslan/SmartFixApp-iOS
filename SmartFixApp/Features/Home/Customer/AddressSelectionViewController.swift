//
//  AddressSelectionViewController.swift
//  SmartFixApp
//
//  Created by Oğuzhan Abuhanoğlu on 9.05.2026.
//

import UIKit

final class AddressSelectionViewController: UIViewController {

    private let selectedAddressId: String?
    private let onSelect: (UserAddress) -> Void

    private var addresses: [UserAddress] = []

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    init(
        selectedAddressId: String?,
        onSelect: @escaping (UserAddress) -> Void
    ) {
        self.selectedAddressId = selectedAddressId
        self.onSelect = onSelect
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        setupTableView()
        layoutConstraints()
        fetchAddresses()
    }

    private func setup() {
        title = "Select Address"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
    }

    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AddressCell")
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func layoutConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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
                        self.tableView.setEmptyMessage("No addresses found.")
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

    private func addressDescription(_ address: UserAddress) -> String {
        "\(address.neighborhood), \(address.street), bina no: \(address.buildingNumber), daire: \(address.doorNumber), kat: \(address.floor)"
    }
}

// MARK: - UITableViewDataSource

extension AddressSelectionViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        addresses.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let address = addresses[indexPath.row]
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "AddressCell",
            for: indexPath
        )

        var content = cell.defaultContentConfiguration()
        content.text = "\(address.city) / \(address.state)"
        content.textProperties.font = .systemFont(ofSize: 17, weight: .semibold)

        content.secondaryText = addressDescription(address)
        content.secondaryTextProperties.font = .systemFont(ofSize: 15, weight: .regular)
        content.secondaryTextProperties.color = .secondaryLabel
        content.secondaryTextProperties.numberOfLines = 0

        cell.contentConfiguration = content
        cell.accessoryType = address.id == selectedAddressId ? .checkmark : .none

        return cell
    }
}

// MARK: - UITableViewDelegate

extension AddressSelectionViewController: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let address = addresses[indexPath.row]

        onSelect(address)

        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.popViewController(animated: true)
    }
}
