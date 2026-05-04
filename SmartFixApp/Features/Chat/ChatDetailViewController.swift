//
//  ChatDetailViewController.swift
//  SmartFixApp
//
//  Created by Ahmet Hakan Karaaslan on 7.04.2026.
//

import UIKit

final class ChatDetailViewController: UIViewController {

    private let chatRoomId: String
    private let participantName: String
    private let requestTitle: String
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

    private var messages: [Message] = []

    init(chatRoomId: String, participantName: String, requestTitle: String, currentUserRole: UserRole) {
        self.chatRoomId = chatRoomId
        self.participantName = participantName
        self.requestTitle = requestTitle
        self.currentUserRole = currentUserRole
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupActions()
//        loadMessages()
    }

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
            tableView.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor),

            messageTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -12)
        ])
    }

    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MessageCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
    }

    private func setupActions() {
//        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
    }

//    private func loadMessages() {
//        messages = MockDataProvider.shared.messages(for: chatRoomId)
//        tableView.reloadData()
//
//        if !messages.isEmpty {
//            let lastIndex = IndexPath(row: messages.count - 1, section: 0)
//            tableView.scrollToRow(at: lastIndex, at: .bottom, animated: false)
//        }
//    }
//
//    @objc private func sendButtonTapped() {
//        let text = (messageTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
//
//        guard !text.isEmpty else { return }
//
//        let newMessage = Message(
//            id: UUID().uuidString,
//            text: text,
//            senderRole: currentUserRole
//        )
//
//        MockDataProvider.shared.addMessage(newMessage, for: chatRoomId)
//        messageTextField.text = nil
//        loadMessages()
//    }
}

extension ChatDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)

        var content = cell.defaultContentConfiguration()
        content.text = message.text
        content.textProperties.numberOfLines = 0

        if message.senderRole == currentUserRole {
            content.textProperties.color = .systemBlue
            cell.contentView.semanticContentAttribute = .forceRightToLeft
        } else {
            content.textProperties.color = .label
            cell.contentView.semanticContentAttribute = .forceLeftToRight
        }

        cell.contentConfiguration = content
        cell.selectionStyle = .none
        return cell
    }
}

extension ChatDetailViewController: UITableViewDelegate {
}
