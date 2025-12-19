//
//  FilterChip.swift
//  keet
//
//  Created by Néstor on 19.12.25.
//

import SwiftUI

struct FilterChip: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.keetCaption)
                    .fontWeight(isSelected ? .semibold : .regular)
                
                if count > 0 {
                    Text("\(count)")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(isSelected ? Color.terracotta : Color.warmBrown.opacity(0.6))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(isSelected ? Color.white.opacity(0.3) : Color.warmBrown.opacity(0.1))
                        )
                }
            }
            .foregroundStyle(isSelected ? Color.white : Color.warmBrown)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.terracotta : Color.cardBackground)
            )
            .overlay(
                Capsule()
                    .strokeBorder(
                        isSelected ? Color.clear : Color.warmBrown.opacity(0.2),
                        lineWidth: 1
                    )
            )
            .keetShadow(intensity: isSelected ? .medium : .light)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack {
        FilterChip(title: "All", count: 10, isSelected: true) {
            print("Selected")
        }
        
        FilterChip(title: "🔥 Hot", count: 5, isSelected: false) {
            print("Selected")
        }
    }
    .padding()
}
