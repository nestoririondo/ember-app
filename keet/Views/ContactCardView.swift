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
    
    var body: some View {
        Button(action: onTap) {
            GeometryReader { geometry in
                ZStack {
                    // Background image or placeholder
                    if let imageData = contact.imageData,
                       let uiImage = UIImage(data:imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                            .saturation(contact.agingSaturation) // Desaturate as contact ages
                            .opacity(contact.agingOpacity)
                    } else {
                        // Placeholder background with design system color
                        contact.agingColor.opacity(0.2)
                        
                        // Centered icon
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .foregroundStyle(contact.agingColor.opacity(0.4))
                    }
                    
                    // Strong gradient overlay for text readability (only with photos)
                    if contact.imageData != nil {
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
                    
                    // Content overlay at bottom
                    VStack(alignment: .leading, spacing: 0) {
                        Spacer()
                        
                        // Name
                        Text(contact.name)
                            .font(.keetHeadline)
                            .foregroundStyle(contact.imageData != nil ? .white : contact.agingTextColor)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                        
                        // Contextual time (human-readable)
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
            .aspectRatio(0.75, contentMode: .fill) // 3:4 portrait aspect ratio
            .clipShape(RoundedRectangle(cornerRadius: .keetCornerLarge))
            .overlay(
                RoundedRectangle(cornerRadius: .keetCornerLarge)
                    .strokeBorder(contact.agingColor.opacity(0.3), lineWidth: 2)
            )
            .keetShadow(intensity: .medium)
        }
        .buttonStyle(.plain)
    }
}

