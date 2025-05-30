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
    private var persistenceManager = PersistenceManager.instance
    
    func loadSessions() async {
        sessions = persistenceManager.loadStoredSessions()
        
        do {
            let fetchedSessions = try await networkService.fetchSessions()
            await MainActor.run {
                self.sessions = fetchedSessions
            }
            persistenceManager.syncSessions(fetchedSessions)
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to fetch sessions: \(error.localizedDescription)"
            }
        }
    }
    
    func sendMessage(_ text: String, in sessionId: String) async {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let newMessage = Message(
            id: UUID().uuidString,
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
            id: UUID().uuidString,
            text: "This is a simulated AI response. In a real app, this would come from the backend.",
            sender: .ai,
            timestamp: ISO8601DateFormatter().string(from: Date())
        )
        
        if let index = sessions.firstIndex(where: { $0.id == sessionId }) {
            var updatedSession = sessions[index]
            updatedSession.messages.append(aiResponse)
            sessions[index] = updatedSession
        }
    }
    
    func createNewSession(title: String, category: String) async throws -> Session {
        let newSession = Session(
            id: UUID().uuidString,
            date: ISO8601DateFormatter().string(from: Date()),
            title: title,
            category: category,
            summary: "New session about \(title)",
            messages: []
        )
        
        // Add the new session to the local state
        sessions.append(newSession)
        
        // Here you would typically make an API call to create the session on the backend
        // For now, we'll just return the local session
        return newSession
    }
}
