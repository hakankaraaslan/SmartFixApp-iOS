//
//  ChatDateSeparatorCell.swift
//  SmartFixApp
//
//  Created by Oğuzhan Abuhanoğlu on 18.05.2026.
//

import UIKit

final class ChatDateSeparatorCell: UITableViewCell {

    static let identifier = "ChatDateSeparatorCell"

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        return view
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(containerView)
        containerView.addSubview(dateLabel)

        containerView.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            containerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            dateLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 6),
            dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -6),
            dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 14),
            dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -14)
        ])
    }

    func configure(text: String) {
        dateLabel.text = text
    }
}
