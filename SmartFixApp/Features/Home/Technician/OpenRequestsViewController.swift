//
//  OpenRequestsViewController.swift
//  SmartFixApp
//
//  Created by Ahmet Hakan Karaaslan on 7.04.2026.
//

import UIKit

final class OpenRequestsViewController: UIViewController {

    private enum TechnicianRequestFilter {
        case open
        case pending
        case accepted
        case rejected
    }
    
    private var openRequests: [RepairRequestModel] = []
    private var offers: [OfferModel] = []
    private var selectedFilter: TechnicianRequestFilter = .open

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    private let statusSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Open", "Pending", "Accepted", "Rejected"])
        control.selectedSegmentIndex = 0
        return control
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupActions()
        loadCurrentSegment()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCurrentSegment()
    }

    private func loadCurrentSegment() {
        switch selectedFilter {
        case .open:
            loadOpenRequests()
        case .pending:
            loadOffers(status: .pending)
        case .accepted:
            loadOffers(status: .accepted)
        case .rejected:
            loadOffers(status: .rejected)
        }
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

    private func loadOpenRequests() {
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
                        self.openRequests = []
                        self.tableView.reloadData()
                        self.tableView.setEmptyMessage("Technician city not found.")
                        return
                    }

                    let cityKey = city.normalizedCityKey

                    RequestService.shared.fetchRequestsForTechnician(cityKey: cityKey) { [weak self] requestResult in
                        DispatchQueue.main.async {
                            guard let self else { return }

                            switch requestResult {
                            case .success(let requests):
                                OfferService.shared.fetchAllOffersForTechnician(technicianId: uid) { [weak self] offerResult in
                                    DispatchQueue.main.async {
                                        guard let self else { return }

                                        switch offerResult {
                                        case .success(let myOffers):
                                            let offeredRequestIds = Set(myOffers.map { $0.requestId })

                                            self.openRequests = requests
                                                .filter { $0.status == .open }
                                                .filter { !offeredRequestIds.contains($0.id) }

                                            self.offers = []
                                            self.tableView.reloadData()

                                            if self.openRequests.isEmpty {
                                                self.tableView.setEmptyMessage("No open requests in your city.")
                                            } else {
                                                self.tableView.restore()
                                            }

                                        case .failure(let error):
                                            self.openRequests = []
                                            self.tableView.reloadData()
                                            self.tableView.setEmptyMessage("Could not load offers.")
                                            print("Fetch technician offers error:", error.localizedDescription)
                                        }
                                    }
                                }

                            case .failure(let error):
                                self.openRequests = []
                                self.tableView.reloadData()
                                self.tableView.setEmptyMessage("Could not load requests.")
                                print("Fetch technician requests error:", error.localizedDescription)
                            }
                        }
                    }

                case .failure(let error):
                    self.openRequests = []
                    self.tableView.reloadData()
                    self.tableView.setEmptyMessage("Could not load technician profile.")
                    print("Fetch technician user error:", error.localizedDescription)
                }
            }
        }
    }

    @objc private func statusSegmentChanged() {
        switch statusSegmentedControl.selectedSegmentIndex {
        case 0:
            selectedFilter = .open
            loadOpenRequests()

        case 1:
            selectedFilter = .pending
            loadOffers(status: .pending)

        case 2:
            selectedFilter = .accepted
            loadOffers(status: .accepted)

        case 3:
            selectedFilter = .rejected
            loadOffers(status: .rejected)

        default:
            selectedFilter = .open
            loadOpenRequests()
        }
    }
    
    private func loadOffers(status: OfferStatus) {
        guard let technicianId = AuthService.shared.currentUserId else {
            tableView.setEmptyMessage("User session not found.")
            return
        }

        OfferService.shared.fetchOffersForTechnician(
            technicianId: technicianId,
            status: status
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                switch result {
                case .success(let offers):
                    self.offers = offers
                    self.openRequests = []
                    self.tableView.reloadData()

                    if offers.isEmpty {
                        self.tableView.setEmptyMessage("No \(status.rawValue) offers.")
                    } else {
                        self.tableView.restore()
                    }

                case .failure(let error):
                    self.offers = []
                    self.tableView.reloadData()
                    self.tableView.setEmptyMessage("Could not load offers.")
                    print("Fetch offers error:", error.localizedDescription)
                }
            }
        }
    }
    
   
}

extension OpenRequestsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch selectedFilter {
        case .open:
            return openRequests.count
        case .pending, .accepted, .rejected:
            return offers.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OpenRequestCell", for: indexPath)

        var content = cell.defaultContentConfiguration()

        switch selectedFilter {
        case .open:
            let request = openRequests[indexPath.row]
            content.text = request.title
            content.secondaryText = "\(request.category) • \(request.deviceName) • \(request.status.rawValue)"

        case .pending, .accepted, .rejected:
            let offer = offers[indexPath.row]
            content.text = offer.requestTitle
            content.secondaryText = "\(offer.requestCategory) • ₺\(offer.price) • \(offer.status.rawValue)"
        }

        content.secondaryTextProperties.color = .secondaryLabel
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

extension OpenRequestsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch selectedFilter {
        case .open:
            let request = openRequests[indexPath.row]
            let vc = OfferCreateViewController(requestId: request.id)
            navigationController?.pushViewController(vc, animated: true)

        case .pending, .accepted, .rejected:
            let offer = offers[indexPath.row]
            let vc = OfferCreateViewController(requestId: offer.requestId)
            navigationController?.pushViewController(vc, animated: true)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}
