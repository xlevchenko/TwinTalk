//
//  NetworkService.swift
//  TwinTalk
//
//  Created by Olexsii Levchenko on 29.05.2025.
//

import Foundation

final class NetworkService {
    
    static let shared = NetworkService()
    
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    private let baseURL = "https://run.mocky.io/v3"
    private let sessionsEndpoint = "/83dc79dc-d16b-42a2-beda-05c7072a0937"
    private let messageEndpoint = "/your-post-mock-id"
    
    private init() {
        // Configure URLSession with timeouts
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.waitsForConnectivity = true
        
        self.session = URLSession(configuration: config)
        
        // Configure decoder
        self.decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        // Configure encoder
        self.encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
    }
    
    // MARK: - Public Methods
    
    /// Fetches a list of sessions from the server
    /// - Returns: An array of sessions
    /// - Throws: NetworkError in case of failure
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
    
    /// Sends a message to a specific session
    /// - Parameters:
    ///   - message: The message to be sent
    ///   - sessionId: Identifier of the target session
    /// - Throws: NetworkError in case of failure
    func sendMessage(_ message: Message, to sessionId: String) async throws {
        let urlString = baseURL + messageEndpoint
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        do {
            let payload = SendMessagePayload(sessionId: sessionId, message: message)
            let request = try createPostRequest(url: url, payload: payload)
            
            let (_, response) = try await session.data(for: request)
            try validateResponse(response)
        } catch let error as NetworkError {
            throw error
        } catch let encodingError as EncodingError {
            throw NetworkError.encodingError(encodingError)
        } catch let urlError as URLError {
            throw mapURLError(urlError)
        } catch {
            throw NetworkError.unknown(error)
        }
    }
}

// MARK: - Private Extensions
private extension NetworkService {
    
    /// Validates an HTTP response
    /// - Parameter response: The URLResponse to validate
    /// - Throws: NetworkError if the response is invalid
    func validateResponse(_ response: URLResponse) throws {
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
    
    /// Creates a POST request with a JSON payload
    /// - Parameters:
    ///   - url: The request URL
    ///   - payload: The data to send
    /// - Returns: A configured URLRequest
    /// - Throws: NetworkError if encoding fails
    func createPostRequest<T: Encodable>(url: URL, payload: T) throws -> URLRequest {
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
    
    /// Maps URLError to a corresponding NetworkError
    /// - Parameter urlError: The URLError to map
    /// - Returns: A matching NetworkError
    func mapURLError(_ urlError: URLError) -> NetworkError {
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
}
