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

    private var chatRooms: [ChatRoomModel] = []

    // MARK: Init
    init(role: UserRole) {
        self.role = role
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Lifecycle
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
    
    // MARK: Chats
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

    // MARK: DATA
    private func loadChatRooms() {
        guard let uid = AuthService.shared.currentUserId else {
            tableView.setEmptyMessage("User session not found.")
            return
        }

        ChatService.shared.fetchChatRooms(
            userId: uid,
            role: role
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                switch result {
                case .success(let rooms):
                    self.chatRooms = rooms
                    self.tableView.reloadData()

                    if rooms.isEmpty {
                        self.tableView.setEmptyMessage("No chats yet.")
                    } else {
                        self.tableView.restore()
                    }

                case .failure(let error):
                    self.chatRooms = []
                    self.tableView.reloadData()
                    self.tableView.setEmptyMessage("Could not load chats.")
                    print("Fetch chat rooms error:", error.localizedDescription)
                }
            }
        }
    }

 
}

// MARK: EXTENSION TABLEVIEW
extension ChatListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chatRooms.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let room = chatRooms[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath)

        let participantName: String

        switch role {
        case .customer:
            participantName = room.technicianName
        case .technician:
            participantName = room.customerName
        }

        var content = cell.defaultContentConfiguration()
        content.text = participantName
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

        let participantName: String

        switch role {
        case .customer:
            participantName = room.technicianName
        case .technician:
            participantName = room.customerName
        }

        let chatDetailVC = ChatDetailViewController(
            chatRoomId: room.id,
            participantName: participantName,
            requestTitle: room.requestTitle,
            currentUserRole: role
        )
        

        chatDetailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatDetailVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
