//
//  NetworkError.swift
//  TwinTalk
//
//  Created by Olexsii Levchenko on 30.05.2025.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case invalidResponse
    case serverError(Int)
    case networkUnavailable
    case timeout
    case decodingError(Error)
    case encodingError(Error)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .invalidResponse:
            return "Invalid response"
        case .serverError(let code):
            return "Server error with code: \(code)"
        case .networkUnavailable:
            return "Network unavailable"
        case .timeout:
            return "Request timeout"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Encoding error: \(error.localizedDescription)"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}
