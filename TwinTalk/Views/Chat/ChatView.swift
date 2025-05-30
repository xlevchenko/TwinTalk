//
//  ChatView.swift
//  TwinTalk
//
//  Created by Olexsii Levchenko on 29.05.2025.
//

import SwiftUI

struct ChatView: View {
    let sessionId: String
    @EnvironmentObject var viewModel: TwinTalkViewModel
    @State private var messageText = ""
    @State private var isSending = false
    @FocusState private var isInputFocused: Bool
    
    private var currentSession: Session? {
        viewModel.sessions.first { $0.id == sessionId }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let session = currentSession {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(session.messages, id: \.timestamp) { message in
                                MessageBubble(message: message)
                                    .id(message.timestamp)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: session.messages.count) { _ in
                        if let lastMessage = session.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.timestamp, anchor: .bottom)
                            }
                        }
                    }
                }
                
                VStack(spacing: 0) {
                    Divider()
                    HStack(spacing: 12) {
                        TextField("Type a message...", text: $messageText, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .focused($isInputFocused)
                            .disabled(isSending)
                            .lineLimit(1...5)
                        
                        Button(action: sendMessage) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue)
                        }
                        .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color(.systemBackground))
            } else {
                Text("Session not found")
                    .foregroundColor(.gray)
            }
        }
        .navigationTitle(currentSession?.title ?? "Chat")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }
    
    private func sendMessage() {
        let text = messageText
        messageText = ""
        isSending = true
        isInputFocused = false
        
        Task {
            await viewModel.sendMessage(text, in: sessionId)
            isSending = false
        }
    }
}

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

#Preview {
    NavigationView {
        ChatView(sessionId: "1")
            .environmentObject(TwinTalkViewModel())
    }
}
