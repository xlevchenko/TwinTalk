//
//  TabBarView.swift
//  TwinTalk
//
//  Created by Olexsii Levchenko on 29.05.2025.
//

import SwiftUI

struct TabBarView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HistoryView(selectedTab: $selectedTab)
                .tabItem {
                    Label("All Sessions", systemImage: "clock")
                }
                .tag(0)
            CreateSession()
                .tabItem {
                    Label("New Session", systemImage: "message")
                }
                .tag(1)
        }
    }
}

#Preview {
    TabBarView()
}
