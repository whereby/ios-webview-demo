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
              let url = URL(string: urlString) else {
            showAlert(message: "Invalid URL. Please enter a valid URL.")
            return
        }
        
        // If loading a Whereby room URL directly, consider adding necessary URL parameters, either programatically or in the input textField.
        // More info here: https://docs.whereby.com/whereby-101/customizing-rooms/using-url-parameters
        // url.addQueryParameters(["skipMediaPermissionPrompt"])
        
        // Ensure the URL is valid
        guard isValidURL(url) else {
            showAlert(message: "Please enter a valid URL with http or https scheme.")
            return
        }
        
        // Instantiate the WebViewController
        guard let webViewController = storyboard?.instantiateViewController(withIdentifier: "WebViewController") as? WebViewController else {
            return
        }
        webViewController.url = url
        navigationController?.pushViewController(webViewController, animated: true)
    }
    
    private func isValidURL(_ url: URL) -> Bool {
        return url.scheme == "http" || url.scheme == "https"
    }
}
