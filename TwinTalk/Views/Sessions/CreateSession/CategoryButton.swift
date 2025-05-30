//
//  CategoryButton.swift
//  TwinTalk
//
//  Created by Olexsii Levchenko on 30.05.2025.
//

import SwiftUI

struct CategoryButton: View {
    let category: ChatCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: category.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : category.color)
                
                Text(category.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ?
                          category.color : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? category.color : Color.gray.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: isSelected ? category.color.opacity(0.3) : .clear,
                   radius: 8, x: 0, y: 4)
        }
    }
}
