//
//  WebViewController.swift
//  WherebyWebViewDemo-iOS
//
//  Created by Remi QUINTO on 12/03/2025.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    internal var url: URL!
    
    private var webView: WKWebView!
    private var fileDownloadDestinationURLs: [WKDownload: URL] = [:]
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
    }
    
    // MARK: - Private
    
    private func setupWebView() {
        
        // Create a configuration for the WKWebView:
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        // Initialize the WKWebView with the custom configuration and delegate:
        webView = WKWebView(frame: .zero, configuration: config)
        webView.uiDelegate = self
        
        // Add the webView to the view hierarchy:
        view.addSubview(webView)
        
        // Apply constraints to the webView (margin = 0 means full screen):
        let margin: CGFloat = 0
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: margin),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -margin),
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: margin),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -margin)
        ])

        // Load the WebView:
        guard let url = url else {
            showAlert(message: "Invalid URL")
            return
        }
        webView.load(URLRequest(url: url))
    }
}

// MARK: - WKUIDelegate

extension WebViewController: WKUIDelegate {
    
    // By default, the WKWebView component will prompt the user for granting camera and microphone access to the website everytime the url is loaded. The following methods allow to override this media permission alert.
    // For iOS 15-16:
    func webView(_ webView: WKWebView, requestMediaCapturePermissionForOrigin origin: URL, initiatedByFrame frame: WKFrameInfo, decisionHandler: @escaping (WKPermissionDecision) -> Void) {
        decisionHandler(.grant)
    }

    // Available on iOS 17+ :
    @MainActor
    func webView(_ webView: WKWebView, decideMediaCapturePermissionsFor origin: WKSecurityOrigin, initiatedBy frame: WKFrameInfo, type: WKMediaCaptureType) async -> WKPermissionDecision {
        return .grant
    }
    
    // The Whereby pre-call screen and room might contain links that would usually redirect the user to a new browser tab or window, such as "Privacy policy", "help" or shared file preview.
    // This delegate method allows to decide how to handle these links.
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard let url = navigationAction.request.url else {
            return nil
        }
        
        // There are a few possibilities:
        
        // 1. Open the url in the default browser:
        // UIApplication.shared.open(url, options: [:], completionHandler: nil)
        
        // 2. Open the url within the WebView (this might result in the current user leaving the meeting):
        // webView.load(URLRequest(url: url))
        
        // 3. Do not open any redirect link:
        return nil
    }
}

// MARK: - WKDownloadDelegate

extension WebViewController: WKDownloadDelegate {
    
    // Handle shared file download
    func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
        download.delegate = self
    }
    
    func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String) async -> URL? {
        
        // Use a temporary URL so the system will automatically clean the files:
        let tempDirectory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        
        // A UUID allows to download the same file multiple times. Otherwise the URL would already exist:
        let uuid = UUID().uuidString
        
        let destinationURL = tempDirectory.appendingPathComponent("\(uuid)_\(suggestedFilename)")
        fileDownloadDestinationURLs[download] = destinationURL
        return destinationURL
    }
    
    func download(_ download: WKDownload, didFailWithError error: Error, resumeData: Data?) {
        let errorMessage = (error as NSError).localizedFailureReason ?? error.localizedDescription
        showAlert(message: "Failed to download file: \(errorMessage)")
        fileDownloadDestinationURLs.removeValue(forKey: download)
    }
    
    func downloadDidFinish(_ download: WKDownload) {
        guard let fileURL = fileDownloadDestinationURLs[download] else {
            return
        }
        
        // There are several ways to store a file, one of them is to simply present a document picker:
        presentDocumentPicker(with: fileURL)
        fileDownloadDestinationURLs.removeValue(forKey: download)
    }
}

// MARK: - UIDocumentPickerDelegate

extension WebViewController: UIDocumentPickerDelegate {
    
    // Helper method for presenting a document picker. Not part of UIDocumentPickerDelegate protocol.
    func presentDocumentPicker(with fileURL: URL) {
        let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        showAlert(message: "File saved to: \(urls.first?.path ?? "unknown location")")
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        showAlert(message: "Document picker cancelled")
    }
}
