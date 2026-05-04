//
//  ChatListViewController.swift
//  SmartFixApp
//
//  Created by Ahmet Hakan Karaaslan on 7.04.2026.
//

import UIKit

final class ChatListViewController: UIViewController {

    private let role: UserRole
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    private var chatRooms: [ChatRoom] = []

    init(role: UserRole) {
        self.role = role
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadChatRooms()
        setupUI()
        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadChatRooms()
    }

    private func loadChatRooms() {
//        switch role {
//        case .customer:
////             chatRooms = MockDataProvider.shared.customerChatRooms
//        case .technician:
////            chatRooms = MockDataProvider.shared.technicianChatRooms
//        }

        tableView.reloadData()
    }

    private func setupUI() {
        title = "Chats"
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ChatCell")
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension ChatListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chatRooms.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let room = chatRooms[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath)

        var content = cell.defaultContentConfiguration()
        content.text = room.participantName
        content.secondaryText = "\(room.requestTitle) • \(room.lastMessage)"
        content.secondaryTextProperties.color = .secondaryLabel

        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

extension ChatListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let room = chatRooms[indexPath.row]

        let chatDetailVC = ChatDetailViewController(
            chatRoomId: room.id,
            participantName: room.participantName,
            requestTitle: room.requestTitle,
            currentUserRole: role
        )
        navigationController?.pushViewController(chatDetailVC, animated: true)

        tableView.deselectRow(at: indexPath, animated: true)
    }
}
