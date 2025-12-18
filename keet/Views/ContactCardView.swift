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
    
    @State private var isPressed: Bool = false
    
    var body: some View {
        Button(action: handleTap) {
            cardContent
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.94 : 1)
        .rotation3DEffect(
            .degrees(isPressed ? 4 : 0),
            axis: (x: 1, y: 0, z: 0)
        )
        .animation(
            .spring(
                response: 0.15,
                dampingFraction: 0.25,
                blendDuration: 2
            ),
            value: isPressed
        )
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
        .onLongPressGesture(minimumDuration: 0.5, maximumDistance: 10) {
            // Context menu will appear, reset the pressed state
        } onPressingChanged: { pressing in
            if !pressing {
                isPressed = false
            }
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
                
                if contact.imageData != nil {
                    gradientOverlay
                }
                
                textOverlay
            }
        }
        .aspectRatio(0.75, contentMode: .fill)
        .clipShape(RoundedRectangle(cornerRadius: .keetCornerLarge))
        .overlay(
            RoundedRectangle(cornerRadius: .keetCornerLarge)
                .strokeBorder(contact.agingColor.opacity(0.3), lineWidth: 2)
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
                .opacity(contact.agingOpacity)
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
    
    private var gradientOverlay: some View {
        LinearGradient(
            colors: [
                .black.opacity(0.7),
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
}

