//
//  MessageBubble.swift
//  TwinTalk
//
//  Created by Olexsii Levchenko on 30.05.2025.
//

import SwiftUI

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.sender == .user {
                Spacer()
            }
            
            VStack(alignment: message.sender == .user ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .padding(12)
                    .background(message.sender == .user ? Color.blue : Color(.systemGray5))
                    .foregroundColor(message.sender == .user ? .white : .primary)
                    .cornerRadius(16)
                
                Text(formattedTime(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            if message.sender == .AI {
                Spacer()
            }
        }
    }
    
    private func formattedTime(_ isoDate: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: isoDate) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
        return isoDate
    }
}
