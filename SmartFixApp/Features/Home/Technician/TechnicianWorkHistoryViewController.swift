//
//  TechnicianWorkHistoryViewController.swift
//  SmartFixApp
//
//  Created by Oğuzhan Abuhanoğlu on 5.05.2026.
//

import UIKit

final class TechnicianWorkHistoryViewController: UIViewController {

    private var offers: [OfferModel] = []
    private var selectedStatus: OfferStatus = .completed

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    private let statusSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Completed", "Cancelled"])
        control.selectedSegmentIndex = 0
        return control
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupActions()
        loadOffers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadOffers()
    }

    private func setupUI() {
        title = "Work History"
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "HistoryCell")
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

    @objc private func statusSegmentChanged() {
        switch statusSegmentedControl.selectedSegmentIndex {
        case 0:
            selectedStatus = .completed
        case 1:
            selectedStatus = .cancelled
        default:
            selectedStatus = .completed
        }

        loadOffers()
    }

    private func loadOffers() {
        guard let technicianId = AuthService.shared.currentUserId else {
            tableView.setEmptyMessage("User session not found.")
            return
        }

        OfferService.shared.fetchOffersForTechnician(
            technicianId: technicianId,
            status: selectedStatus
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                switch result {
                case .success(let offers):
                    self.offers = offers
                    self.tableView.reloadData()

                    if offers.isEmpty {
                        self.tableView.setEmptyMessage("No \(self.selectedStatus.rawValue) work history.")
                    } else {
                        self.tableView.restore()
                    }

                case .failure(let error):
                    self.offers = []
                    self.tableView.reloadData()
                    self.tableView.setEmptyMessage("Could not load work history.")
                    print("Fetch technician work history error:", error.localizedDescription)
                }
            }
        }
    }
}

extension TechnicianWorkHistoryViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        offers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let offer = offers[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)

        var content = cell.defaultContentConfiguration()
        content.text = offer.requestTitle
        content.secondaryText = "\(offer.requestCategory) • \(offer.requestDeviceName) • ₺\(offer.price) • \(offer.status.rawValue)"
        content.secondaryTextProperties.color = .secondaryLabel

        cell.contentConfiguration = content
        cell.accessoryType = .none

        return cell
    }
}

extension TechnicianWorkHistoryViewController: UITableViewDelegate {
}
