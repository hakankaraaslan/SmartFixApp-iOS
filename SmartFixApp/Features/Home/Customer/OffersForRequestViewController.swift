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

    // MARK: Lifecycle
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

    
    // MARK: Setup
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

    // MARK: DATA
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
    
    // Accept offer flow
    private func acceptOffer(_ offer: OfferModel) {
        OfferService.shared.updateOfferStatus(
            offerId: offer.id,
            status: .accepted
        ) { [weak self] offerResult in
            DispatchQueue.main.async {
                guard let self else { return }

                switch offerResult {
                case .success:
                    self.updateRequestAfterAccepting(offer)

                case .failure(let error):
                    self.showAlert(title: "Offer Error", message: error.localizedDescription)
                }
            }
        }
    }

    private func updateRequestAfterAccepting(_ offer: OfferModel) {
        RequestService.shared.acceptOfferForRequest(
            requestId: offer.requestId,
            offer: offer
        ) { [weak self] requestResult in
            DispatchQueue.main.async {
                guard let self else { return }

                switch requestResult {
                case .success:
                    self.rejectOtherOffersAndCreateChat(offer)

                case .failure(let error):
                    self.showAlert(title: "Request Error", message: error.localizedDescription)
                }
            }
        }
    }

    private func rejectOtherOffersAndCreateChat(_ offer: OfferModel) {
        OfferService.shared.rejectOtherOffers(
            requestId: offer.requestId,
            acceptedOfferId: offer.id
        ) { [weak self] rejectResult in
            DispatchQueue.main.async {
                guard let self else { return }

                switch rejectResult {
                case .success:
                    self.createChatRoom(for: offer)

                case .failure(let error):
                    self.showAlert(title: "Reject Offers Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    
    private func createChatRoom(for offer: OfferModel) {
        guard let customerId = AuthService.shared.currentUserId else {
            showAlert(title: "Auth Error", message: "Customer not found.")
            return
        }

        FirestoreService.shared.fetchUser(uid: customerId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                switch result {
                case .success(let customer):
                    let chatRoomId = "\(offer.requestId)_\(offer.technicianId)"

                    let chatRoom = ChatRoomModel(
                        id: chatRoomId,
                        requestId: offer.requestId,
                        requestTitle: self.requestTitle,
                        customerId: customer.uid,
                        customerName: customer.fullName,
                        technicianId: offer.technicianId,
                        technicianName: offer.technicianName,
                        lastMessage: "Chat started",
                        createdAt: Date().timeIntervalSince1970
                    )

                    ChatService.shared.createChatRoom(chatRoom: chatRoom) { [weak self] chatResult in
                        DispatchQueue.main.async {
                            guard let self else { return }

                            switch chatResult {
                            case .success:
                                let chatVC = ChatDetailViewController(
                                    chatRoomId: chatRoom.id,
                                    participantName: offer.technicianName,
                                    requestTitle: self.requestTitle,
                                    currentUserRole: .customer
                                )

                                self.navigationController?.pushViewController(chatVC, animated: true)

                            case .failure(let error):
                                self.showAlert(title: "Chat Error", message: error.localizedDescription)
                            }
                        }
                    }

                case .failure(let error):
                    self.showAlert(title: "Customer Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    
    private func rejectOffer(_ offer: OfferModel) {
        OfferService.shared.updateOfferStatus(
            offerId: offer.id,
            status: .rejected
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                switch result {
                case .success:
                    self.loadOffers()

                case .failure(let error):
                    self.showAlert(title: "Reject Failed", message: error.localizedDescription)
                }
            }
        }
    }
    
    
    // MARK: Helpers
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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

        let alert = UIAlertController(
            title: "Manage Offer",
            message: """
            Technician: \(offer.technicianName)
            Price: ₺\(offer.price)
            Estimated Time: \(offer.estimatedTime)
            """,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Accept", style: .default) { [weak self] _ in
            self?.acceptOffer(offer)
        })
        
        alert.addAction(UIAlertAction(title: "Reject", style: .destructive) { [weak self] _ in
            self?.rejectOffer(offer)
        })

        present(alert, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
