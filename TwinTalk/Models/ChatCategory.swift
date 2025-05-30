//
//  ChatCategory.swift
//  TwinTalk
//
//  Created by Olexsii Levchenko on 30.05.2025.
//

import Foundation
import SwiftUI

enum ChatCategory: String, CaseIterable {
    case career = "Career"
    case emotions = "Emotions"
    case productivity = "Productivity"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .career: return "briefcase.fill"
        case .emotions: return "heart.fill"
        case .productivity: return "chart.line.uptrend.xyaxis"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .career: return .blue
        case .emotions: return .pink
        case .productivity: return .green
        case .other: return .purple
        }
    }
}
