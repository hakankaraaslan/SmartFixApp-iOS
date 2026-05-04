//
//  OffersForRequestViewController.swift
//  SmartFixApp
//
//  Created by Ahmet Hakan Karaaslan on 7.04.2026.
//

import UIKit

final class OffersForRequestViewController: UIViewController {

    private let requestId: String
    private let requestTitle: String

    private var offers: [OfferModel] = []

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    init(requestId: String, requestTitle: String) {
        self.requestId = requestId
        self.requestTitle = requestTitle
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        loadOffers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadOffers()
    }

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
        OfferService.shared.fetchOffersForRequest(requestId: requestId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                switch result {
                case .success(let offers):
                    self.offers = offers
                    self.tableView.reloadData()

                    if offers.isEmpty {
                        self.tableView.setEmptyMessage("No offers yet.")
                    } else {
                        self.tableView.restore()
                    }

                case .failure(let error):
                    self.offers = []
                    self.tableView.reloadData()
                    self.tableView.setEmptyMessage("Could not load offers.")
                    print("Fetch offers for request error:", error.localizedDescription)
                }
            }
        }
    }
}


// MARK: - UITableViewDataSource
extension OffersForRequestViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        offers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let offer = offers[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "OfferCell", for: indexPath)

        var content = cell.defaultContentConfiguration()
        content.text = "\(offer.technicianName) - ₺\(offer.price)"
        content.secondaryText = "Estimated Time: \(offer.estimatedTime) • Status: \(offer.status.rawValue)"
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
        print("Selected offer:", offer.id)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//extension OffersForRequestViewController: UITableViewDelegate {
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let offer = offers[indexPath.row]
//
//        let alert = UIAlertController(
//            title: "Accept Offer?",
//            message: """
//            Technician: \(offer.technicianName)
//            Price: ₺\(offer.price)
//            Estimated Time: \(offer.estimatedTime)
//            """,
//            preferredStyle: .alert
//        )
//
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//
//        alert.addAction(UIAlertAction(title: "Accept", style: .default) { _ in
//            if let customerIndex = MockDataProvider.shared.customerRequests.firstIndex(where: { $0.id == offer.requestId }) {
//                let existingRequest = MockDataProvider.shared.customerRequests[customerIndex]
//
//                let updatedRequest = Request(
//                    id: existingRequest.id,
//                    category: existingRequest.category,
//                    title: existingRequest.title,
//                    detailDescription: existingRequest.detailDescription,
//                    brand: existingRequest.brand,
//                    model: existingRequest.model,
//                    status: .accepted
//                )
//
//                MockDataProvider.shared.customerRequests[customerIndex] = updatedRequest
//            }
//
//            if let openIndex = MockDataProvider.shared.openRequests.firstIndex(where: { $0.id == offer.requestId }) {
//                MockDataProvider.shared.openRequests.remove(at: openIndex)
//            }
//
//            self.loadOffers()
//
//            let existingChatRoom = MockDataProvider.shared.customerChatRooms.first {
//                $0.requestId == offer.requestId && $0.participantName == offer.technicianName
//            }
//
//            let chatRoomId: String
//
//            if let existingChatRoom = existingChatRoom {
//                chatRoomId = existingChatRoom.id
//            } else {
//                let newChatRoom = ChatRoom(
//                    id: UUID().uuidString,
//                    requestId: offer.requestId,
//                    participantName: offer.technicianName,
//                    requestTitle: self.requestTitle,
//                    lastMessage: "Chat started"
//                )
//
//                MockDataProvider.shared.customerChatRooms.append(newChatRoom)
//                MockDataProvider.shared.technicianChatRooms.append(newChatRoom)
//                chatRoomId = newChatRoom.id
//            }
//
//            let chatDetailVC = ChatDetailViewController(
//                chatRoomId: chatRoomId,
//                participantName: offer.technicianName,
//                requestTitle: self.requestTitle,
//                currentUserRole: .customer
//            )
//            self.navigationController?.pushViewController(chatDetailVC, animated: true)
//        })
//
//        present(alert, animated: true)
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
//}
