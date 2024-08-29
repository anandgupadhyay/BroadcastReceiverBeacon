//
//  ToastView.swift
//  BroadcastReceiverBeacon
//
//  Created by Anand Upadhyay on 28/08/24.
//

import Foundation
import UIKit
class ToastView: UIView {
    private var messageLabel: UILabel!

    init(message: String) {
        super.init(frame: CGRect.zero)
        configureUI(message: message)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func configureUI(message: String) {
        // Customize your toast view's appearance
        backgroundColor = UIColor.black.withAlphaComponent(0.8)
        layer.cornerRadius = 10
        clipsToBounds = true

        messageLabel = UILabel(frame: CGRect.zero)
        messageLabel.text = message
        messageLabel.textColor = UIColor.white
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.systemFont(ofSize: 15)

        addSubview(messageLabel)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
}

extension UIViewController {
    func showToast(message: String, duration: TimeInterval = 2.0) {
        let toastView = ToastView(message: message)
        view.addSubview(toastView)
        toastView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toastView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            toastView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            toastView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
            UIView.animate(withDuration: 0.3, animations: {
                toastView.alpha = 0
            }, completion: { _ in
                toastView.removeFromSuperview()
            })
        }
    }
}

