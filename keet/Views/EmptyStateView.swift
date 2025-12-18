//
//  EmptyStateView.swift
//  keet
//
//  Created by Néstor on 17.12.25.
//

import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: .keetSpacingXL) {
            Spacer()
            
            // App Icon
            Image(systemName: "flame.fill")
                .font(.system(size: 80))
                .foregroundStyle(.terracotta)
                .symbolEffect(.breathe)
            
            // Title
            Text("Welcome to Ember")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.warmBrown)
            
            // Subtitle
            Text("Keep your meaningful relationships warm")
                .font(.headline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            // Tutorial Steps
            VStack(alignment: .leading, spacing: .keetSpacingL) {
                TutorialRow(
                    icon: "person.crop.circle.badge.plus",
                    text: "Add people you want to keep in touch with"
                )
                
                TutorialRow(
                    icon: "calendar.badge.clock",
                    text: "Mark when you've reached out to them"
                )
                
                TutorialRow(
                    icon: "flame",
                    text: "Contacts you haven't talked to in a while will start to fade",
                    opacity: 0.6
                )
            }
            .padding()
            .background(Color.white.opacity(0.8))
            .cornerRadius(16)
            .padding(.horizontal, .keetSpacingXL)
            
            // CTA
            Text("Tap the **+** button to add your first contact")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// Tutorial Row Component
private struct TutorialRow: View {
    let icon: String
    let text: String
    var opacity: Double = 1.0
    
    var body: some View {
        HStack(alignment: .top, spacing: .keetSpacingL) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.terracotta)
                .frame(width: 32)
                .opacity(opacity)
            
            Text(text)
                .font(.body)
                .foregroundStyle(.warmBrown)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    EmptyStateView()
}
