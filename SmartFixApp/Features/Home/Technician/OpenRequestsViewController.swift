//
//  OpenRequestsViewController.swift
//  SmartFixApp
//
//  Created by Ahmet Hakan Karaaslan on 7.04.2026.
//

import UIKit

final class OpenRequestsViewController: UIViewController {

    struct OpenRequest {
        let category: String
        let problemTitle: String
        let shortDescription: String
    }

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    private var requests: [OpenRequest] = [
        OpenRequest(
            category: "White Goods",
            problemTitle: "Refrigerator is not cooling",
            shortDescription: "Customer reports that the fridge stopped cooling yesterday."
        ),
        OpenRequest(
            category: "Electrical",
            problemTitle: "Power outlet is not working",
            shortDescription: "One wall outlet in the living room is not providing power."
        ),
        OpenRequest(
            category: "Plumbing",
            problemTitle: "Kitchen sink leakage",
            shortDescription: "Water is leaking from under the sink cabinet."
        )
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
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
}

extension OpenRequestsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        requests.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let request = requests[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "OpenRequestCell", for: indexPath)

        var content = cell.defaultContentConfiguration()
        content.text = request.problemTitle
        content.secondaryText = "\(request.category) • \(request.shortDescription)"
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
            requestTitle: request.problemTitle,
            category: request.category,
            descriptionText: request.shortDescription
        )
        navigationController?.pushViewController(offerVC, animated: true)

        tableView.deselectRow(at: indexPath, animated: true)
    }
}
