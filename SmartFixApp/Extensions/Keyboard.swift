//
//  Keyboard.swift
//  SmartFixApp
//
//  Created by Oğuzhan Abuhanoğlu on 18.05.2026.
//

import Foundation
import UIKit

extension UIViewController {

    func setupKeyboardObservers(for scrollView: UIScrollView) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )

        objc_setAssociatedObject(
            self,
            &AssociatedKeys.scrollView,
            scrollView,
            .OBJC_ASSOCIATION_ASSIGN
        )
    }

    @objc private func handleKeyboardWillShow(_ notification: Notification) {
        guard
            let scrollView = objc_getAssociatedObject(
                self,
                &AssociatedKeys.scrollView
            ) as? UIScrollView,
            let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else {
            return
        }

        let keyboardHeight = keyboardFrame.height

        scrollView.contentInset.bottom = keyboardHeight + 24
        scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight
    }

    @objc private func handleKeyboardWillHide(_ notification: Notification) {
        guard
            let scrollView = objc_getAssociatedObject(
                self,
                &AssociatedKeys.scrollView
            ) as? UIScrollView
        else {
            return
        }

        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }
}

private struct AssociatedKeys {
    static var scrollView = "keyboard_scrollview"
}
