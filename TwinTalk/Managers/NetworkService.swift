//
//  NetworkService.swift
//  TwinTalk
//
//  Created by Olexsii Levchenko on 29.05.2025.
//

import Foundation

// MARK: - URLSession Protocol for testing
protocol URLSessionProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

final class NetworkService {
    
    static let shared = NetworkService()
    
    private let session: URLSessionProtocol
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    private let baseURL = "https://run.mocky.io/v3"
    private let sessionsEndpoint = "/cd42a6b7-6dc3-4681-bb68-ab4b355a4928"
    private let messageEndpoint = "/your-post-mock-id"
    
    // **MARK: - Initializers**
    
    private convenience init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.waitsForConnectivity = true
        let session = URLSession(configuration: config)
        self.init(session: session)
    }
    
    // Designated initializer for testing
    internal init(session: URLSessionProtocol) {
        self.session = session
        
        // Configure decoder
        self.decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        // Configure encoder
        self.encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
    }
    
    // **MARK: - Public Methods**
    
    func fetchSessions() async throws -> [Session] {
        let urlString = baseURL + sessionsEndpoint
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            try validateResponse(response)
            
            guard !data.isEmpty else {
                throw NetworkError.noData
            }
            
            let sessions = try decoder.decode([Session].self, from: data)
            return sessions
            
        } catch let error as NetworkError {
            throw error
        } catch let decodingError as DecodingError {
            throw NetworkError.decodingError(decodingError)
        } catch let urlError as URLError {
            throw mapURLError(urlError)
        } catch {
            throw NetworkError.unknown(error)
        }
    }
}

// **MARK: - Internal Extensions (for testing)**

extension NetworkService {
    
    internal func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return
        case 400...499, 500...599:
            throw NetworkError.serverError(httpResponse.statusCode)
        default:
            throw NetworkError.invalidResponse
        }
    }
    
    internal func createPostRequest<T: Encodable>(url: URL, payload: T) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            request.httpBody = try encoder.encode(payload)
        } catch {
            throw NetworkError.encodingError(error)
        }
        
        return request
    }
    
    internal func mapURLError(_ urlError: URLError) -> NetworkError {
        switch urlError.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return .networkUnavailable
        case .timedOut:
            return .timeout
        case .badURL:
            return .invalidURL
        case .badServerResponse:
            return .invalidResponse
        default:
            return .unknown(urlError)
        }
    }
    
    // Factory method for testing
    static func createForTesting(session: URLSessionProtocol) -> NetworkService {
        return NetworkService(session: session)
    }
}

// **MARK: - Testing Extensions**
extension NetworkService {
    // Expose internal methods for testing with proper naming
    func testValidateResponse(_ response: URLResponse) throws {
        try validateResponse(response)
    }
    
    func testCreatePostRequest<T: Encodable>(url: URL, payload: T) throws -> URLRequest {
        return try createPostRequest(url: url, payload: payload)
    }
    
    func testMapURLError(_ urlError: URLError) -> NetworkError {
        return mapURLError(urlError)
    }
}
