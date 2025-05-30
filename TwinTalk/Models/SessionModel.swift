//
//  SessionModel.swift
//  TwinTalk
//
//  Created by Olexsii Levchenko on 29.05.2025.
//

import Foundation

struct Session: Codable, Identifiable {
    let id: String
    let date: String
    let title: String
    let category: String
    let summary: String
    var messages: [Message]
}

struct Message: Codable, Identifiable, Hashable {
    let id: String
    let text: String
    let sender: Sender
    let timestamp: String
}

enum Sender: String, Codable {
    case user
    case ai
}
