//
//  HistoryView.swift
//  TwinTalk
//
//  Created by Olexsii Levchenko on 29.05.2025.
//

import SwiftUI

struct HistoryView: View {
    
    @EnvironmentObject var viewModel: TwinTalkViewModel
    @Binding var selectedTab: Int
    @State private var isRefreshing = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Button(action: {
                        selectedTab = 1
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 20))
                            Text("Start New Session")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [Color.blue, Color.blue.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: Color.blue.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.sessions) { session in
                            SessionCardView(session: session)
                        }
                    }
                }
            }
            .navigationTitle("AI Sessions")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            isRefreshing = true
                            await viewModel.loadSessions()
                            try? await Task.sleep(nanoseconds: 500_000_000)
                            isRefreshing = false
                        }
                    }) {
                        if isRefreshing {
                            ProgressView()
                                .tint(.blue)
                        } else {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    .disabled(isRefreshing)
                }
            }
            .task {
                await viewModel.loadSessions()
            }
        }
    }
}

struct SessionCardView: View {
    let session: Session
    
    var body: some View {
        NavigationLink(destination: ChatSessionView(sessionId: session.id)) {
            VStack(alignment: .leading, spacing: 8) {
                Text(formattedDate(session.date))
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(session.title)
                    .font(.title3)
                    .fontWeight(.semibold)
                Text(session.category.capitalized)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                Text(session.summary)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formattedDate(_ isoDate: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: isoDate) {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
        return isoDate
    }
}

#Preview {
    HistoryView(selectedTab: .constant(0))
        .environmentObject(TwinTalkViewModel())
}
