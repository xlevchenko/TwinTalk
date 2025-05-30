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
    
    // WebSocket properties
    private let webSocketURL = "wss://your-websocket-server.com/ws"
    private var webSocketTask: URLSessionWebSocketTask?
    private var messageHandlers: [String: (Message) -> Void] = [:]
    
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
    
    // MARK: - Original HTTP Methods for imitation of receiving data and sending messages
    
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

// MARK: - WebSocket Methods
extension NetworkService {
    /// Establishes WebSocket connection
    func connectWebSocket() {
        guard let url = URL(string: webSocketURL) else {
            print("Invalid WebSocket URL")
            return
        }
        
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        
        // Start listening for messages
        listenForMessages()
    }
    
    /// Disconnects WebSocket
    func disconnectWebSocket() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        messageHandlers.removeAll()
    }
    
    /// Registers a handler for receiving AI responses for a specific session
    /// - Parameters:
    ///   - sessionId: The session ID to listen for
    ///   - handler: Callback function to handle received messages
    func registerMessageHandler(for sessionId: String, handler: @escaping (Message) -> Void) {
        messageHandlers[sessionId] = handler
    }
    
    /// Removes message handler for a session
    /// - Parameter sessionId: The session ID to stop listening for
    func removeMessageHandler(for sessionId: String) {
        messageHandlers.removeValue(forKey: sessionId)
    }
    
    /// Sends a message through WebSocket and waits for AI response
    /// - Parameters:
    ///   - message: The message to send
    ///   - sessionId: The session ID
    func sendMessageViaWebSocket(_ message: Message, to sessionId: String) async throws {
        guard let webSocketTask = webSocketTask else {
            throw NetworkError.webSocketNotConnected
        }
        
        let payload = WebSocketMessage(
            type: .user,
            sessionId: sessionId,
            message: message
        )
        
        let jsonData = try encoder.encode(payload)
        let messageString = String(data: jsonData, encoding: .utf8) ?? ""
        
        try await webSocketTask.send(.string(messageString))
    }
    
    // MARK: - Private WebSocket Methods
    
    private func listenForMessages() {
        guard let webSocketTask = webSocketTask else { return }
        
        webSocketTask.receive { [weak self] result in
            switch result {
            case .success(let message):
                self?.handleWebSocketMessage(message)
                // Continue listening
                self?.listenForMessages()
                
            case .failure(let error):
                print("WebSocket receive error: \(error)")
                // Attempt to reconnect after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self?.connectWebSocket()
                }
            }
        }
    }
    
    private func handleWebSocketMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let text):
            handleTextMessage(text)
        case .data(let data):
            if let text = String(data: data, encoding: .utf8) {
                handleTextMessage(text)
            }
        @unknown default:
            break
        }
    }
    
    private func handleTextMessage(_ text: String) {
        guard let data = text.data(using: .utf8) else { return }
        
        do {
            let webSocketResponse = try decoder.decode(WebSocketResponse.self, from: data)
            
            // Handle different message types
            switch webSocketResponse.type {
            case .AI:
                if let handler = messageHandlers[webSocketResponse.sessionId] {
                    DispatchQueue.main.async {
                        handler(webSocketResponse.message)
                    }
                }
            default:
                break
            }
            
        } catch {
            print("Failed to decode WebSocket message: \(error)")
        }
    }
    
}

// MARK: - Private Extensions
private extension NetworkService {
    
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
