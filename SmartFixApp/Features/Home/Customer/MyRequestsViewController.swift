//
//  MyRequestsViewController.swift
//  SmartFixApp
//
//  Created by Ahmet Hakan Karaaslan on 7.04.2026.
//

import UIKit

final class MyRequestsViewController: UIViewController {

    // MARK: - Dummy Model

    

    // MARK: - Properties

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    private var requests: [Request] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        loadRequests()
    }

    // MARK: - Setup

    private func setupUI() {
        title = "My Requests"
        view.backgroundColor = .systemBackground

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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

    private func loadRequests() {
        requests = MockDataProvider.shared.customerRequests
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension MyRequestsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        requests.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let request = requests[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath)

        var content = cell.defaultContentConfiguration()
        content.text = request.title
        content.secondaryText = "\(request.category) • Status: \(request.status.rawValue)"
        content.secondaryTextProperties.color = .secondaryLabel

        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator

        return cell
    }
}

// MARK: - UITableViewDelegate

extension MyRequestsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let request = requests[indexPath.row]

        let detailRequest = RequestDetailViewController.RequestDetail(
            id: request.id,
            category: request.category,
            problemTitle: request.title,
            description: request.detailDescription,
            status: request.status.rawValue
        )

        let detailVC = RequestDetailViewController(request: detailRequest)
        navigationController?.pushViewController(detailVC, animated: true)

        tableView.deselectRow(at: indexPath, animated: true)
    }
}
