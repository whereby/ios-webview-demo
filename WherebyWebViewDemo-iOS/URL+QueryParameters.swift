//
//  URL+QueryParameters.swift
//  WherebyWebViewDemo-iOS
//
//  Created by Remi QUINTO on 12/03/2025.
//

import Foundation

extension URL {
    mutating func addQueryParameters(_ parameters: [String]) {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return }
        
        let queryItems = parameters.compactMap { param -> URLQueryItem? in
            let parts = param.split(separator: "=").map(String.init)
            return parts.count == 1 ? URLQueryItem(name: parts[0], value: nil) :
                   parts.count == 2 ? URLQueryItem(name: parts[0], value: parts[1]) : nil
        }
        
        components.queryItems = (components.queryItems ?? []) + queryItems
        if let newURL = components.url {
            self = newURL
        }
    }
}
