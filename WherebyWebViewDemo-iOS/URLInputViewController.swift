//
//  URLInputViewController.swift
//  WherebyWebViewDemo-iOS
//
//  Created by Remi QUINTO on 27/02/2025.
//

import UIKit

class URLInputViewController: UIViewController {
    
    @IBOutlet private weak var urlInputTextField: UITextField!
    
    @IBAction private func didPressLoadWebViewButton(_ sender: UIButton) {
        loadWebView()
    }
    
    // MARK: - Private
    
    private func loadWebView() {
        guard let urlString = urlInputTextField.text,
              let url = URL(string: urlString),
        isValidURL(url) else {
            showAlert(message: "Invalid URL. Please enter a valid URL.")
            return
        }
        
        guard let webViewController = storyboard?.instantiateViewController(withIdentifier: "WebViewController") as? WebViewController else {
            return
        }
        webViewController.url = url
        navigationController?.pushViewController(webViewController, animated: true)
    }
    
    private func isValidURL(_ url: URL) -> Bool {
        return url.scheme == "http" || url.scheme == "https"
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
