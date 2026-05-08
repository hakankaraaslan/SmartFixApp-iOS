//
//  ProfileHeaderView.swift
//  SmartFixApp
//
//  Created by Oğuzhan Abuhanoğlu on 9.05.2026.
//

import UIKit

final class ProfileHeaderView: UIView {

    // MARK: - UI

    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.crop.circle.fill")
        imageView.tintColor = .systemGray3
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 40
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()

    private let mailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()

    private lazy var labelsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            nameLabel,
            mailLabel
        ])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        return stack
    }()

    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            profileImageView,
            labelsStackView
        ])
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .top
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setupSubviews()
        layoutConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 20
        clipsToBounds = true
    }

    private func setupSubviews() {
        addSubview(contentStackView)
    }

    private func layoutConstraints() {
        NSLayoutConstraint.activate([

            profileImageView.widthAnchor.constraint(equalToConstant: 80),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),

            contentStackView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }

    // MARK: - Configure

    func configure(
        name: String,
        email: String,
        profileImage: UIImage? = nil
    ) {
        nameLabel.text = name
        mailLabel.text = email

        if let profileImage {
            profileImageView.image = profileImage
        }
    }
}
