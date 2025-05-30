//
//  WebSocketMessage.swift
//  TwinTalk
//
//  Created by Olexsii Levchenko on 30.05.2025.
//

import Foundation

// MARK: - WebSocket Data Models

struct WebSocketMessage: Codable {
    let type: Sender
    let sessionId: String
    let message: Message
}

struct WebSocketResponse: Codable {
    let type: Sender
    let sessionId: String
    let message: Message
}
