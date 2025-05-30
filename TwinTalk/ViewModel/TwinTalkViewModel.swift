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
    
    private var networkService = NetworkService.shared
    
    
    func loadSessions() async {
        do {
            sessions = try await networkService.fetchSessions()
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
        
        // Optional: simulate sending message to backend (disabled for now)
        /*
        do {
            try await networkService.sendMessage(newMessage, to: sessionId)
        } catch {
            errorMessage = "Failed to send message: \(error.localizedDescription)"
            return
        }
        */

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
