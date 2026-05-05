//
//  MyRequestsViewController.swift
//  SmartFixApp
//
//  Created by Ahmet Hakan Karaaslan on 7.04.2026.
//

import UIKit

final class MyRequestsViewController: UIViewController {
    // MARK: - Properties
    private var allRequests: [RepairRequestModel] = []
    private var filteredRequests: [RepairRequestModel] = []
    private var selectedStatus: RequestStatus = .open
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    private let statusSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Open", "Accepted", "Completed", "Cancelled"])
        control.selectedSegmentIndex = 0
        return control
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        loadRequests()
        setupActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadRequests()
    }

    // MARK: - Setup
    private func setupUI() {
        title = "My Requests"
        view.backgroundColor = .systemBackground

        view.addSubview(statusSegmentedControl)
        view.addSubview(tableView)

        statusSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            statusSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            statusSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statusSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            statusSegmentedControl.heightAnchor.constraint(equalToConstant: 36),

            tableView.topAnchor.constraint(equalTo: statusSegmentedControl.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "RequestCell")
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func setupActions() {
        statusSegmentedControl.addTarget(
            self,
            action: #selector(statusSegmentChanged),
            for: .valueChanged
        )
    }
    
    private func loadRequests() {
        guard let uid = SessionManager.shared.uid else { return }

        RequestService.shared.fetchRequestsForCustomer(customerId: uid) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                switch result {
                case .success(let requests):
                    self.allRequests = requests
                    self.applyFilter()

                case .failure(let error):
                    print("Fetch requests error:", error.localizedDescription)
                }
            }
        }
    }
    
    @objc private func statusSegmentChanged() {
        switch statusSegmentedControl.selectedSegmentIndex {
        case 0: selectedStatus = .open
        case 1: selectedStatus = .offerAccepted
        case 2: selectedStatus = .completed
        case 3: selectedStatus = .cancelled
        default: selectedStatus = .open
        }

        applyFilter()
    }
    
    private func applyFilter() {
        filteredRequests = allRequests.filter { $0.status == selectedStatus }
        tableView.reloadData()

        if filteredRequests.isEmpty {
            tableView.setEmptyMessage("No \(selectedStatus.rawValue) requests.")
        } else {
            tableView.restore()
        }
    }
}

// MARK: - UITableViewDataSource

extension MyRequestsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredRequests.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let request = filteredRequests[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath)

        var content = cell.defaultContentConfiguration()
        content.text = request.title
        content.secondaryText = "\(request.category) • Status: \(request.status.rawValue)"
        content.secondaryTextProperties.color = .secondaryLabel

        cell.contentConfiguration = content
        cell.accessoryType = selectedStatus == .open ? .disclosureIndicator : .none

        return cell
    }
}

// MARK: - UITableViewDelegate

extension MyRequestsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }

        guard selectedStatus == .open else {
            return
        }

        let request = filteredRequests[indexPath.row]
        let detailVC = RequestDetailsViewController(requestId: request.id)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension UITableView {

    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.textColor = .secondaryLabel
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = .systemFont(ofSize: 16)

        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        let container = UIView()
        container.addSubview(messageLabel)

        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            messageLabel.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -20)
        ])

        self.backgroundView = container
        self.separatorStyle = .none
    }

    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
