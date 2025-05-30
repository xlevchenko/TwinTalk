//
//  HistoryView.swift
//  TwinTalk
//
//  Created by Olexsii Levchenko on 29.05.2025.
//

import SwiftUI

struct HistoryView: View {
    
    @EnvironmentObject var viewModel: TwinTalkViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.sessions) { session in
                        SessionCardView(session: session)
                    }
                }
                .padding(.top)
            }
            .navigationTitle("AI Sessions")
            .task {
                await viewModel.loadSessions()
            }
        }
    }
}

struct SessionCardView: View {
    let session: Session
    
    var body: some View {
        NavigationLink(destination: ChatView(sessionId: session.id)) {
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
    HistoryView()
}
