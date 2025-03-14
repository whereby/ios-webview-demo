//
//  UIViewController+Alert.swift
//  WherebyWebViewDemo-iOS
//
//  Created by Remi QUINTO on 13/03/2025.
//

import UIKit

extension UIViewController {
    func showAlert(title: String = "Error", message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
