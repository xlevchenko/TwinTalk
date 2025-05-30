//
//  ContentView.swift
//  TwinTalk
//
//  Created by Olexsii Levchenko on 29.05.2025.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var viewModel = TwinTalkViewModel()
    
    var body: some View {
        TabBarView()
            .environmentObject(viewModel)
    }
}

#Preview {
    ContentView()
}
