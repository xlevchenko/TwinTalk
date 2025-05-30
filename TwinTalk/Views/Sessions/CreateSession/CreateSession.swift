//
//  CreateSession.swift
//  TwinTalk
//
//  Created by Olexsii Levchenko on 30.05.2025.
//

import SwiftUI

struct CreateSession: View {
    @EnvironmentObject var viewModel: TwinTalkViewModel
    @State private var sessionTopic: String = ""
    @State private var selectedCategory: ChatCategory?
    @State private var navigateToChat = false
    @State private var createdSessionId: String?
    @State private var isCreatingSession = false
    @State private var errorMessage: String?
    
    private var isFormValid: Bool {
        !sessionTopic.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedCategory != nil
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Start a New Chat")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Choose a topic and category to begin your conversation")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 24)
                    
                    // Session Topic Input
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Session Topic")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("What would you like to discuss?", text: $sessionTopic)
                            .font(.body)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemGray6))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                    
                    // Category Selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Select Category")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(ChatCategory.allCases, id: \.self) { category in
                                CategoryButton(
                                    category: category,
                                    isSelected: selectedCategory == category,
                                    action: { selectedCategory = category }
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.subheadline)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.red.opacity(0.1))
                            )
                            .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 32)
                    
                    // Start Session Button
                    Button(action: createNewSession) {
                        HStack {
                            if isCreatingSession {
                                ProgressView()
                                    .tint(.white)
                                    .padding(.trailing, 8)
                            }
                            Text("Start Session")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(isFormValid && !isCreatingSession ? 
                                    LinearGradient(colors: [.blue, .blue.opacity(0.8)], 
                                                 startPoint: .leading, 
                                                 endPoint: .trailing) : 
                                        LinearGradient(colors: [.gray.opacity(0.3)],
                                                     startPoint: .leading,
                                                     endPoint: .trailing))
                        )
                        .shadow(color: isFormValid && !isCreatingSession ? .blue.opacity(0.3) : .clear,
                               radius: 8, x: 0, y: 4)
                    }
                    .disabled(!isFormValid || isCreatingSession)
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $navigateToChat) {
                if let sessionId = createdSessionId {
                    ChatSessionView(sessionId: sessionId)
                }
            }
        }
    }
    
    private func createNewSession() {
        guard let category = selectedCategory else { return }
        
        isCreatingSession = true
        errorMessage = nil
        
        Task {
            do {
                let session = try await viewModel.createNewSession(
                    title: sessionTopic.trimmingCharacters(in: .whitespacesAndNewlines),
                    category: category.rawValue
                )
                
                await MainActor.run {
                    createdSessionId = session.id
                    navigateToChat = true
                    isCreatingSession = false
                    setToNewChat()
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to create session: \(error.localizedDescription)"
                    isCreatingSession = false
                }
            }
        }
    }
    
    private func setToNewChat() {
        sessionTopic = ""
        selectedCategory = nil
    }
}



#Preview {
    CreateSession()
}
