//
//  EmptyStateView.swift
//  keet
//
//  Created by Néstor on 17.12.25.
//

import SwiftUI

struct EmptyStateView: View {
    @State private var isBreathing = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: .keetSpacingL) {
            Spacer()
            
            // App Icon
            Image(colorScheme == .light ? .emberIconNoBg : .emberIconDarkNobg)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .scaleEffect(isBreathing ? 1.1 : 1.0)
                .opacity(isBreathing ? 1 : 0.75)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isBreathing)
                .onAppear {
                    isBreathing = true
                }
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
                .padding(.bottom, 24)
            
            // Tutorial Steps
            VStack(alignment: .leading, spacing: .keetSpacingL) {
                TutorialRow(
                    icon: "person.crop.circle.badge.plus",
                    text: "Add the people who matter most to you"
                )
                
                TutorialRow(
                    icon: "hand.tap",
                    text: "Tap a contact each time you connect with them"
                )
                
                TutorialRow(
                    icon: "thermometer.medium",
                    text: "Watch relationships stay warm or grow cold over time"
                )
            }
            .padding()
            .background(Color.cardBackground.opacity(0.8))
            .cornerRadius(16)
            .padding(.horizontal, .keetSpacingXL)
            
            // CTA
            Text("Tap the **+** button to add your first contact")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            
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
