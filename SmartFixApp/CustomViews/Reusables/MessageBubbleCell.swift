//
//  MessageBubbleCell.swift
//  SmartFixApp
//
//  Created by Oğuzhan Abuhanoğlu on 5.05.2026.
//

import UIKit

final class MessageBubbleCell: UITableViewCell {

    static let identifier = "MessageBubbleCell"

    private let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        return view
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .regular)
        label.textAlignment = .right
        return label
    }()

    private lazy var bubbleStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            messageLabel,
            timeLabel
        ])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        messageLabel.text = nil
        timeLabel.text = nil
        leadingConstraint.isActive = false
        trailingConstraint.isActive = false
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(bubbleView)
        bubbleView.addSubview(bubbleStackView)

        bubbleView.translatesAutoresizingMaskIntoConstraints = false

        leadingConstraint = bubbleView.leadingAnchor.constraint(
            equalTo: contentView.leadingAnchor,
            constant: 16
        )

        trailingConstraint = bubbleView.trailingAnchor.constraint(
            equalTo: contentView.trailingAnchor,
            constant: -16
        )

        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.72),

            bubbleStackView.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 10),
            bubbleStackView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 14),
            bubbleStackView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -14),
            bubbleStackView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -8)
        ])
    }

    func configure(message: MessageModel, isCurrentUser: Bool) {
        messageLabel.text = message.text
        timeLabel.text = message.createdAt.chatTimeStringTR

        leadingConstraint.isActive = !isCurrentUser
        trailingConstraint.isActive = isCurrentUser

        if isCurrentUser {
            bubbleView.backgroundColor = .systemBlue
            messageLabel.textColor = .white
            timeLabel.textColor = UIColor.white.withAlphaComponent(0.75)
        } else {
            bubbleView.backgroundColor = .secondarySystemBackground
            messageLabel.textColor = .label
            timeLabel.textColor = .secondaryLabel
        }
    }
}
