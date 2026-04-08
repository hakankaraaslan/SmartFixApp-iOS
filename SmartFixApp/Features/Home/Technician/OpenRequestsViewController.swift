//
//  OpenRequestsViewController.swift
//  SmartFixApp
//
//  Created by Ahmet Hakan Karaaslan on 7.04.2026.
//

import UIKit

final class OpenRequestsViewController: UIViewController {

    

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    private var requests: [Request] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        loadRequests()
    }

    private func setupUI() {
        title = "Open Requests"
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "OpenRequestCell")
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func loadRequests() {
        requests = MockDataProvider.shared.openRequests.filter { $0.status == .open }
        tableView.reloadData()
    }
}

extension OpenRequestsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        requests.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let request = requests[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "OpenRequestCell", for: indexPath)

        var content = cell.defaultContentConfiguration()
        content.text = request.title
        content.secondaryText = "\(request.category) • \(request.detailDescription)"
        content.secondaryTextProperties.color = .secondaryLabel

        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

extension OpenRequestsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let request = requests[indexPath.row]

        let offerVC = OfferCreateViewController(
            requestId: request.id,
            requestTitle: request.title,
            category: request.category,
            descriptionText: request.detailDescription
        )
        navigationController?.pushViewController(offerVC, animated: true)

        tableView.deselectRow(at: indexPath, animated: true)
    }
}
