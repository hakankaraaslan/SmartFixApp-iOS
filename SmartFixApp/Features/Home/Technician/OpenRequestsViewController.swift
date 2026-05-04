//
//  OpenRequestsViewController.swift
//  SmartFixApp
//
//  Created by Ahmet Hakan Karaaslan on 7.04.2026.
//

import UIKit

final class OpenRequestsViewController: UIViewController {

    private var allRequests: [RepairRequestModel] = []
    private var filteredRequests: [RepairRequestModel] = []
    private var selectedStatus: RequestStatus = .open

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    private let statusSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Open", "Accepted", "Completed", "Cancelled"])
        control.selectedSegmentIndex = 0
        return control
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupActions()
        loadRequests()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadRequests()
    }

    private func setupUI() {
        title = "Requests"
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "OpenRequestCell")
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
        guard let uid = AuthService.shared.currentUserId else {
            tableView.setEmptyMessage("User session not found.")
            return
        }

        FirestoreService.shared.fetchUser(uid: uid) { [weak self] userResult in
            DispatchQueue.main.async {
                guard let self else { return }

                switch userResult {
                case .success(let user):
                    guard let city = user.address?.city, !city.isEmpty else {
                        self.allRequests = []
                        self.applyFilter()
                        self.tableView.setEmptyMessage("Technician city not found.")
                        return
                    }

                    let cityKey = city.normalizedCityKey

                    RequestService.shared.fetchRequestsForTechnician(cityKey: cityKey) { [weak self] requestResult in
                        DispatchQueue.main.async {
                            guard let self else { return }

                            switch requestResult {
                            case .success(let requests):
                                self.allRequests = requests
                                self.applyFilter()

                            case .failure(let error):
                                self.allRequests = []
                                self.applyFilter()
                                self.tableView.setEmptyMessage("Could not load requests.")
                                print("Fetch technician requests error:", error.localizedDescription)
                            }
                        }
                    }

                case .failure(let error):
                    self.allRequests = []
                    self.applyFilter()
                    self.tableView.setEmptyMessage("Could not load technician profile.")
                    print("Fetch technician user error:", error.localizedDescription)
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
            tableView.setEmptyMessage("No \(selectedStatus.rawValue) requests in your city.")
        } else {
            tableView.restore()
        }
    }
}

extension OpenRequestsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredRequests.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let request = filteredRequests[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "OpenRequestCell", for: indexPath)

        var content = cell.defaultContentConfiguration()
        content.text = request.title
        content.secondaryText = "\(request.category) • \(request.deviceName) • \(request.status.rawValue)"
        content.secondaryTextProperties.color = .secondaryLabel

        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

extension OpenRequestsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let request = filteredRequests[indexPath.row]

        let offerVC = OfferCreateViewController(
            requestId: request.id,
            requestTitle: request.title,
            category: request.category,
            descriptionText: request.detailDescription,
            brand: request.brand,
            model: request.model
        )

        navigationController?.pushViewController(offerVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
