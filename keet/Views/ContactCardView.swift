//
//  ContactCardView.swift
//  keet
//
//  Created by Néstor on 16.12.25.
//

import SwiftUI

struct ContactCardView: View {
    let contact: Contact
    let onTap: () -> Void
    
    @State private var isPressed = false
        
    var body: some View {
        cardContent
            .scaleEffect(isPressed ? 0.94 : 1)
            .rotation3DEffect(
                .degrees(isPressed ? 4 : 0),
                axis: (x: 1, y: 0, z: 0)
            )
            .animation(.spring(response: 0.2, dampingFraction: 0.5), value: isPressed)
            .onTapGesture {
                // Trigger press animation
                withAnimation(.spring(response: 0.15, dampingFraction: 0.5)) {
                    isPressed = true
                }
                
                // Reset after a brief moment
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isPressed = false
                    }
                }
                
                handleTap()
            }
    }
    
    private func handleTap() {
        onTap()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    private var cardContent: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundContent(geometry: geometry)

                
                // Show warm overlay for contacts contacted today
                if contact.daysSinceLastContact == 0 {
                    warmOverlay
                } else {
                    coolOverlay
                }
                
                // Add frosty border glow for cold contacts
                if contact.frostIntensity > 0 {
                    frostyBorderGlow
                }
                
                
                if contact.imageData != nil {
                    gradientOverlay
                }
                
                textOverlay
                
                birthdayChip
            }
        }
        .aspectRatio(0.75, contentMode: .fill)
        .clipShape(RoundedRectangle(cornerRadius: .keetCornerLarge))
        .overlay(
            RoundedRectangle(cornerRadius: .keetCornerLarge)
                .strokeBorder(
                    contact.frostIntensity > 0 
                        ? Color(red: 0.7, green: 0.85, blue: 0.98)  // Glacier ice blue
                        : contact.agingColor.opacity(0.8),  // Visible warm border
                    lineWidth: 3
                )
        )
        .keetShadow(intensity: .medium)
        .animation(.easeInOut(duration: 0.3), value: contact.lastContacted)
    }
    
    @ViewBuilder
    private func backgroundContent(geometry: GeometryProxy) -> some View {
        if let imageData = contact.imageData,
           let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
                .saturation(contact.agingSaturation)
        } else {
            ZStack {
                contact.agingColor.opacity(0.2)
                
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .foregroundStyle(contact.agingColor.opacity(0.4))
            }
        }
    }

    @ViewBuilder
    private var birthdayChip: some View {
        if let birthdayText = contact.birthdayText {
            let isToday = birthdayText == "Today!"
            
            HStack(spacing: 4) {
                Text("🎁")
                    .font(.system(size: 12))
                Text(birthdayText)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(
                        isToday
                            ? Color(red: 1.0, green: 0.6, blue: 0.3)  // Warm orange for today
                            : Color.black.opacity(0.5)  // Dark for upcoming
                    )
            )
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            .scaleEffect(isToday ? 1.05 : 1.0)
            .animation(
                isToday
                    ? .easeInOut(duration: 1.0).repeatForever(autoreverses: true)
                    : .default,
                value: isToday
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .padding(.keetSpacingS)
        }
    }
    

    
    private var gradientOverlay: some View {
        LinearGradient(
            colors: [
                .black.opacity(0.8),
                .black.opacity(0.4),
                .clear
            ],
            startPoint: .bottom,
            endPoint: .center
        )
    }
    
    private var textOverlay: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            
            Text(contact.name)
                .font(.keetHeadline)
                .foregroundStyle(contact.imageData != nil ? .white : contact.agingTextColor)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            
            Text(contact.lastContactedText)
                .font(.keetCaption)
                .foregroundStyle((contact.imageData != nil ? Color.white : contact.agingTextColor).opacity(0.9))
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        .padding(.keetSpacingL)
    }
    
    private var coolOverlay: some View {
        RadialGradient(
            colors: [
                Color.clear,
                Color(red: 0.6, green: 0.85, blue: 1.0).opacity(contact.coolOverlayOpacity * 0.45),
                Color(red: 0.5, green: 0.75, blue: 0.95).opacity(contact.coolOverlayOpacity * 1.5),
            ],
            center: .center,
            startRadius: 10,
            endRadius: 180
        )
        .blendMode(.screen)
    }
    
    private var warmOverlay: some View {
        RadialGradient(
            colors: [
                Color.clear,
                Color(red: 1.0, green: 0.75, blue: 0.4).opacity(0.25),
                Color(red: 1.0, green: 0.6, blue: 0.3).opacity(0.6)
            ],
            center: .center,
            startRadius: 10,
            endRadius: 400
        )
        .blendMode(.screen)
    }

    
    private var frostyBorderGlow: some View {
        let intensity = contact.frostIntensity
        
        return ZStack {
            // Layer 1: Strong glacier blue glow from top-left
            RoundedRectangle(cornerRadius: .keetCornerLarge)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color(red: 0.7, green: 0.85, blue: 0.98).opacity(1.0 * intensity),  // Full opacity
                            Color(red: 0.75, green: 0.88, blue: 0.98).opacity(0.8 * intensity),
                            Color(red: 0.8, green: 0.9, blue: 0.98).opacity(0.5 * intensity),
                            Color.white.opacity(0.3 * intensity),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .center
                    ),
                    lineWidth: 20
                )
                .blur(radius: 8)
            
            // Layer 2: Glacier blue glow from bottom-right
            RoundedRectangle(cornerRadius: .keetCornerLarge)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color(red: 0.7, green: 0.85, blue: 0.98).opacity(1.0 * intensity),
                            Color(red: 0.75, green: 0.88, blue: 0.98).opacity(0.8 * intensity),
                            Color(red: 0.8, green: 0.9, blue: 0.98).opacity(0.5 * intensity),
                            Color.white.opacity(0.3 * intensity),
                            Color.clear
                        ],
                        startPoint: .bottomTrailing,
                        endPoint: .center
                    ),
                    lineWidth: 20
                )
                .blur(radius: 8)
            
            // Layer 3: Sharp inner frost ring
            RoundedRectangle(cornerRadius: .keetCornerLarge)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color(red: 0.65, green: 0.82, blue: 0.96).opacity(0.9 * intensity),
                            Color.white.opacity(0.6 * intensity),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .center
                    ),
                    lineWidth: 12
                )
                .blur(radius: 3)
        }
    }
}

//#Preview("Today - Warm Glow") {
//    ContactCardView(contact: Contact(name: "Just Contacted", lastContacted: Date())) {
//        print("tapped")
//    }
//    .frame(width: 200, height: 267)
//    .padding()
//}
//#Preview("20 Days - Cool Tint") {
//    ContactCardView(contact: Contact(name: "Getting Cold", lastContacted: Date().addingTimeInterval(-1728000))) { // 20 days
//        print("tapped")
//    }
//    .frame(width: 200, height: 267)
//    .padding()
//}

#Preview("40 Days - Needs Attention") {
    ContactCardView(contact: Contact(name: "Needs Love", lastContacted: Date().addingTimeInterval(-3456000), birthdayDate: Date().addingTimeInterval(650000)
                                    )) { // 40 days
        print("tapped")
    }
    
    .frame(width: 200, height: 267)
    .padding()
}


