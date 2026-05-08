//
//  DismissKeyboard.swift
//  SmartFixApp
//
//  Created by Oğuzhan Abuhanoğlu on 9.05.2026.
//

import UIKit

extension UIViewController {

    func setupKeyboardDismissGesture() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )

        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
