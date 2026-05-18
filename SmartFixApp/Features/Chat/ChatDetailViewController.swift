//
//  ChatDetailViewController.swift
//  SmartFixApp
//
//  Created by Ahmet Hakan Karaaslan on 7.04.2026.
//

import UIKit
import FirebaseFirestore

final class ChatDetailViewController: UIViewController {

    private enum ChatItem {
        case date(String)
        case message(MessageModel)
    }
    
    private var messages: [MessageModel] = []
    private var chatItems: [ChatItem] = []
    private var listener: ListenerRegistration?

    private let chatRoomId: String
    private let participantName: String
    private let currentUserRole: UserRole

    private let tableView = UITableView(frame: .zero, style: .plain)

    private let inputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        return view
    }()

    private let messageTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Type a message..."
        textField.borderStyle = .roundedRect
        return textField
    }()

    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        return button
    }()

    // MARK: - Init

    init(chatRoomId: String, participantName: String, requestTitle: String, currentUserRole: UserRole) {
        self.chatRoomId = chatRoomId
        self.participantName = participantName
        self.currentUserRole = currentUserRole
        super.init(nibName: nil, bundle: nil)
    }

    deinit {
        listener?.remove()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupActions()
        listenMessages()
    }

    // MARK: - Setup

    private func setupUI() {
        title = participantName
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never

        view.addSubview(tableView)
        view.addSubview(inputContainerView)

        inputContainerView.addSubview(messageTextField)
        inputContainerView.addSubview(sendButton)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        inputContainerView.translatesAutoresizingMaskIntoConstraints = false
        messageTextField.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            inputContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // Klavye açılınca inputContainer klavyenin üstüne çıkar
            inputContainerView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),

            inputContainerView.heightAnchor.constraint(equalToConstant: 70),

            messageTextField.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 16),
            messageTextField.centerYAnchor.constraint(equalTo: inputContainerView.centerYAnchor),
            messageTextField.heightAnchor.constraint(equalToConstant: 40),

            sendButton.leadingAnchor.constraint(equalTo: messageTextField.trailingAnchor, constant: 12),
            sendButton.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor, constant: -16),
            sendButton.centerYAnchor.constraint(equalTo: inputContainerView.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 60),

            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor)
        ])
    }

    private func setupTableView() {
        tableView.register(
            MessageBubbleCell.self,
            forCellReuseIdentifier: MessageBubbleCell.identifier
        )

        tableView.register(
            ChatDateSeparatorCell.self,
            forCellReuseIdentifier: ChatDateSeparatorCell.identifier
        )
        
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemBackground
        tableView.keyboardDismissMode = .interactive
    }

    private func setupActions() {
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
    }

    // MARK: - Data

    private func listenMessages() {
        listener = ChatService.shared.listenMessages(chatRoomId: chatRoomId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                switch result {
                case .success(let messages):
                    self.messages = messages
                    self.chatItems = self.buildChatItems(from: messages)
                    self.tableView.reloadData()

                    DispatchQueue.main.async {
                        self.scrollToBottom()
                    }
                case .failure(let error):
                    print("Listen messages error:", error.localizedDescription)
                }
            }
        }
    }

    @objc private func sendButtonTapped() {
        let text = (messageTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        guard !text.isEmpty else { return }
        guard let senderId = AuthService.shared.currentUserId else { return }

        let message = MessageModel(
            id: UUID().uuidString,
            chatRoomId: chatRoomId,
            senderId: senderId,
            senderRole: currentUserRole,
            text: text,
            createdAt: Date().timeIntervalSince1970
        )

        messageTextField.text = nil

        ChatService.shared.sendMessage(
            chatRoomId: chatRoomId,
            message: message
        ) { result in
            if case .failure(let error) = result {
                print("Send message error:", error.localizedDescription)
            }
        }
    }

    // MARK: - Helpers
    private func scrollToBottom() {
        guard !chatItems.isEmpty else { return }

        tableView.layoutIfNeeded()

        let lastSection = tableView.numberOfSections - 1
        guard lastSection >= 0 else { return }

        let lastRow = tableView.numberOfRows(inSection: lastSection) - 1
        guard lastRow >= 0 else { return }

        let indexPath = IndexPath(row: lastRow, section: lastSection)

        DispatchQueue.main.async {
            self.tableView.scrollToRow(
                at: indexPath,
                at: .bottom,
                animated: true
            )
        }
    }
    
    private func buildChatItems(from messages: [MessageModel]) -> [ChatItem] {
        var items: [ChatItem] = []
        var lastDayText: String?

        for message in messages {
            let dayText = message.createdAt.chatDayStringTR

            if dayText != lastDayText {
                items.append(.date(dayText))
                lastDayText = dayText
            }

            items.append(.message(message))
        }

        return items
    }
}

// MARK: - UITableViewDataSource

extension ChatDetailViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let item = chatItems[indexPath.row]

        switch item {
        case .date(let text):
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ChatDateSeparatorCell.identifier,
                for: indexPath
            ) as! ChatDateSeparatorCell

            cell.configure(text: text)
            return cell

        case .message(let message):
            let cell = tableView.dequeueReusableCell(
                withIdentifier: MessageBubbleCell.identifier,
                for: indexPath
            ) as! MessageBubbleCell

            let isCurrentUser = message.senderId == AuthService.shared.currentUserId
            cell.configure(message: message, isCurrentUser: isCurrentUser)
            return cell
        }
    }
}
