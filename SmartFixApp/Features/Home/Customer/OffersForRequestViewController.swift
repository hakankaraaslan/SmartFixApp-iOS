//
//  OffersForRequestViewController.swift
//  SmartFixApp
//
//  Created by Ahmet Hakan Karaaslan on 7.04.2026.
//

import UIKit

final class OffersForRequestViewController: UIViewController {

    // MARK: - Model



    // MARK: - Properties

    private let requestId: String
    private let requestTitle: String
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    private var offers: [Offer] = []

    // MARK: - Init

    init(requestId: String, requestTitle: String) {
        self.requestId = requestId
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
        loadOffers()
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

    private func loadOffers() {
        offers = MockDataProvider.shared.offers(for: requestId)
        tableView.reloadData()
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
        content.secondaryText = "Price: ₺\(offer.price) • Estimated Time: \(offer.estimatedTime)"
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
            Price: ₺\(offer.price)
            Estimated Time: \(offer.estimatedTime)
            """,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Accept", style: .default) { _ in
            let chatRoomId: String

            switch offer.technicianName {
            case "Ahmet Repair Service":
                chatRoomId = "chat-1"
            case "Teknik Destek Pro":
                chatRoomId = "chat-2"
            case "Mehmet Yılmaz":
                chatRoomId = "chat-3"
            case "Ayşe Demir":
                chatRoomId = "chat-4"
            default:
                chatRoomId = "chat-1"
            }

            let chatDetailVC = ChatDetailViewController(
                chatRoomId: chatRoomId,
                participantName: offer.technicianName,
                requestTitle: self.requestTitle
            )
            self.navigationController?.pushViewController(chatDetailVC, animated: true)
        })

        present(alert, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
