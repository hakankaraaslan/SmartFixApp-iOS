//
//  OffersForRequestViewController.swift
//  SmartFixApp
//
//  Created by Ahmet Hakan Karaaslan on 7.04.2026.
//

import UIKit

final class OffersForRequestViewController: UIViewController {

    // MARK: - Model

    struct Offer {
        let technicianName: String
        let price: String
        let estimatedTime: String
    }

    // MARK: - Properties

    private let requestTitle: String
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    private var offers: [Offer] = [
        Offer(technicianName: "Ahmet Repair Service", price: "₺750", estimatedTime: "2 hours"),
        Offer(technicianName: "Teknik Destek Pro", price: "₺680", estimatedTime: "3 hours"),
        Offer(technicianName: "Hızlı Usta", price: "₺820", estimatedTime: "1 hour")
    ]

    // MARK: - Init

    init(requestTitle: String) {
        self.requestTitle = requestTitle
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }

    // MARK: - Setup

    private func setupUI() {
        title = "Offers"
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "OfferCell")
        tableView.dataSource = self
        tableView.delegate = self
    }
}

// MARK: - UITableViewDataSource

extension OffersForRequestViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        offers.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Offers for: \(requestTitle)"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let offer = offers[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "OfferCell", for: indexPath)

        var content = cell.defaultContentConfiguration()
        content.text = offer.technicianName
        content.secondaryText = "Price: \(offer.price) • Estimated Time: \(offer.estimatedTime)"
        content.secondaryTextProperties.color = .secondaryLabel

        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator

        return cell
    }
}

// MARK: - UITableViewDelegate

extension OffersForRequestViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let offer = offers[indexPath.row]

        let alert = UIAlertController(
            title: "Accept Offer?",
            message: """
            Technician: \(offer.technicianName)
            Price: \(offer.price)
            Estimated Time: \(offer.estimatedTime)
            """,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Accept", style: .default) { _ in
            let chatDetailVC = ChatDetailViewController(
                technicianName: offer.technicianName,
                requestTitle: self.requestTitle
            )
            self.navigationController?.pushViewController(chatDetailVC, animated: true)
        })

        present(alert, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
