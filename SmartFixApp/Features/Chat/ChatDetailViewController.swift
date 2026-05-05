//
//  ChatDetailViewController.swift
//  SmartFixApp
//
//  Created by Ahmet Hakan Karaaslan on 7.04.2026.
//

import UIKit
import FirebaseFirestore

final class ChatDetailViewController: UIViewController {

    private var messages: [MessageModel] = []
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

    // MARK: Init
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

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupActions()
        listenMessages()
    }

    // MARK: Setup
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
            inputContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
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
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemBackground
        tableView.keyboardDismissMode = .interactive
    }

    private func setupActions() {
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
    }
    

    // MARK: DATA
    private func listenMessages() {
        listener = ChatService.shared.listenMessages(chatRoomId: chatRoomId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                switch result {
                case .success(let messages):
                    self.messages = messages
                    self.tableView.reloadData()
                    self.scrollToBottom()

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

        ChatService.shared.sendMessage(chatRoomId: chatRoomId, message: message) { result in
            if case .failure(let error) = result {
                print("Send message error:", error.localizedDescription)
            }
        }
    }
    

    // MARK: Helpers
    private func scrollToBottom() {
        guard !messages.isEmpty else { return }

        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
}

// MARK: Extensions - Tableview
extension ChatDetailViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let message = messages[indexPath.row]

        let cell = tableView.dequeueReusableCell(
            withIdentifier: MessageBubbleCell.identifier,
            for: indexPath
        ) as! MessageBubbleCell

        let isCurrentUser = message.senderId == AuthService.shared.currentUserId
        cell.configure(message: message, isCurrentUser: isCurrentUser)

        return cell
    }
}
