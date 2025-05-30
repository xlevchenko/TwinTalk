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
                        .background(Color(.separator).opacity(0.5))
                    HStack(spacing: 12) {
                        HStack(spacing: 8) {
                            TextField("Type a message...", text: $messageText, axis: .vertical)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.primary)
                                .focused($isInputFocused)
                                .disabled(isSending)
                                .lineLimit(1...5)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemGray6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color(.systemGray4), lineWidth: 0.5)
                                )
                        )
                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                        
                        Button(action: sendMessage) {
                            Image(systemName: "arrow.up")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(
                                    Circle()
                                        .fill(
                                            messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                            ? LinearGradient(
                                                colors: [Color.gray, Color.gray.opacity(0.8)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing)
                                            : LinearGradient(
                                                colors: [Color.blue, Color.blue.opacity(0.8)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                )
                                .scaleEffect(isSending ? 0.9 : 1.0)
                                .animation(.easeInOut(duration: 0.1), value: isSending)
                        }
                        .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        Color(.systemBackground)
                            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: -2)
                            .ignoresSafeArea(edges: .bottom)
                    )
                }
            } else {
                Text("Session not found")
                    .foregroundColor(.gray)
            }
        }
        .navigationTitle(currentSession?.title ?? "Chat")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .onDisappear {
            viewModel.stopListening(to: sessionId)
        }
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
