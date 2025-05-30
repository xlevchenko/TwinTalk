//
//  TwinTalkViewModel.swift
//  TwinTalk
//
//  Created by Olexsii Levchenko on 29.05.2025.
//


import Foundation

@MainActor
class TwinTalkViewModel: ObservableObject {
    
    @Published var sessions: [Session] = []
    @Published var errorMessage: String?
    @Published var isWebSocketConnected = false
    
    private var networkService = NetworkService.shared
    
    //MARK: - Uncomment if you what using Socket
//    init() {
//        setupWebSocket()
//    }
//
//    deinit {
//        networkService.disconnectWebSocket()
//    }
//
    
    func loadSessions() async {
        do {
            sessions = try await networkService.fetchSessions()
            
            //MARK: - Register message handlers for all sessions using Socket
//            for session in sessions {
//                registerMessageHandler(for: session.id)
//            }
            
        } catch {
            errorMessage = "Failed to fetch sessions: \(error.localizedDescription)"
        }
    }
    
    func sendMessage(_ text: String, in sessionId: String) async {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let newMessage = Message(
            text: text,
            sender: .user,
            timestamp: ISO8601DateFormatter().string(from: Date())
        )
        
        // Update local state immediately
        if let index = sessions.firstIndex(where: { $0.id == sessionId }) {
            var updatedSession = sessions[index]
            updatedSession.messages.append(newMessage)
            sessions[index] = updatedSession
        }
        
        // Simulated AI response after 1 second
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        let aiResponse = Message(
            text: "This is a simulated AI response. In a real app, this would come from the backend.",
            sender: .AI,
            timestamp: ISO8601DateFormatter().string(from: Date())
        )
        
        if let index = sessions.firstIndex(where: { $0.id == sessionId }) {
            var updatedSession = sessions[index]
            updatedSession.messages.append(aiResponse)
            sessions[index] = updatedSession
        }
    }
}


// MARK: - WebSocket Setup
extension TwinTalkViewModel {
    private func setupWebSocket() {
        networkService.connectWebSocket()
        isWebSocketConnected = true
    }
    
    /// Registers message handler for a specific session
    private func registerMessageHandler(for sessionId: String) {
        networkService.registerMessageHandler(for: sessionId) { [weak self] aiMessage in
            Task { @MainActor in
                self?.handleReceivedAIMessage(aiMessage, in: sessionId)
            }
        }
    }
    
    /// Handles received AI message from WebSocket
    private func handleReceivedAIMessage(_ message: Message, in sessionId: String) {
        if let index = sessions.firstIndex(where: { $0.id == sessionId }) {
            var updatedSession = sessions[index]
            updatedSession.messages.append(message)
            sessions[index] = updatedSession
        }
    }
    
    func sendMessageUsingSocket(_ text: String, in sessionId: String) async {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let newMessage = Message(
            text: text,
            sender: .user,
            timestamp: ISO8601DateFormatter().string(from: Date())
        )
        
        // Update local state immediately
        if let index = sessions.firstIndex(where: { $0.id == sessionId }) {
            var updatedSession = sessions[index]
            updatedSession.messages.append(newMessage)
            sessions[index] = updatedSession
        }
        
        // Send message via WebSocket
        do {
            try await networkService.sendMessageViaWebSocket(newMessage, to: sessionId)
        } catch {
            errorMessage = "Failed to send message: \(error.localizedDescription)"
            
            // If WebSocket fails, try to reconnect
            if case NetworkError.webSocketNotConnected = error {
                reconnectWebSocket()
            }
        }
    }
    
    /// Reconnects WebSocket if connection is lost
    private func reconnectWebSocket() {
        isWebSocketConnected = false
        networkService.disconnectWebSocket()
        
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000) // Wait 1 second
            
            await MainActor.run {
                setupWebSocket()
                
                // Re-register handlers for all sessions
                for session in sessions {
                    registerMessageHandler(for: session.id)
                }
            }
        }
    }
    
    /// Manually reconnect WebSocket (can be called from UI)
    func reconnectIfNeeded() {
        if !isWebSocketConnected {
            reconnectWebSocket()
        }
    }
    
    /// Clean up when switching away from a session
    func stopListening(to sessionId: String) {
        networkService.removeMessageHandler(for: sessionId)
    }
}
