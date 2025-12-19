//
//  DesignSystem.swift
//  keet
//
//  Created by Néstor on 16.12.25.
//

import SwiftUI

// MARK: - Color Palette
extension Color {
    // MARK: - Adaptive Background Colors
    static let softCream = Color(
        light: Color(red: 0.98, green: 0.97, blue: 0.93), // #FAF8ED - Light cream
        dark: Color(red: 0.11, green: 0.11, blue: 0.12)   // #1C1C1E - Dark background
    )
    
    static let cardBackground = Color(
        light: .white,
        dark: Color(red: 0.17, green: 0.17, blue: 0.18)   // #2C2C2E - Elevated dark
    )
    
    // MARK: - Primary Brand Colors (Stay consistent in both modes)
    static let terracotta = Color(red: 0.89, green: 0.49, blue: 0.38) // #E37D61
    static let terracottaLight = Color(red: 0.95, green: 0.70, blue: 0.62) // Lighter variant
    static let terracottaDark = Color(red: 0.75, green: 0.35, blue: 0.25) // Darker variant
    
    static let sageGreen = Color(red: 0.60, green: 0.71, blue: 0.63) // #99B5A1
    static let sageGreenLight = Color(red: 0.75, green: 0.82, blue: 0.77)
    static let sageGreenDark = Color(red: 0.45, green: 0.57, blue: 0.49)
    
    // MARK: - Adaptive Text Colors
    static let warmBrown = Color(
        light: Color(red: 0.53, green: 0.42, blue: 0.35), // #876B59 - Warm brown
        dark: Color(red: 0.85, green: 0.82, blue: 0.78)   // Light warm for dark mode
    )
    
    static let warmBrownLight = Color(
        light: Color(red: 0.70, green: 0.60, blue: 0.52),
        dark: Color(red: 0.70, green: 0.65, blue: 0.60)
    )
    
    // MARK: - Aging Colors (for visual aging effect)
    // Very warm, saturated colors for recent contacts
    static let recentWarm = Color(red: 0.95, green: 0.45, blue: 0.30) // Vibrant warm red-orange
    static let recentVibrant = Color(red: 0.92, green: 0.50, blue: 0.35) // Warm terracotta
    static let fadingWarm = Color(red: 0.85, green: 0.60, blue: 0.45) // Cooling terracotta

    // Transitioning to neutral
    static let fadingNeutral = Color(red: 0.70, green: 0.68, blue: 0.60) // Warm beige (less saturated)

    // Cold, desaturated colors for old contacts
    static let oldCool = Color(red: 0.65, green: 0.68, blue: 0.70) // Cool blue-gray (desaturated)
    static let oldFaded = Color(red: 0.75, green: 0.75, blue: 0.75) // Very desaturated gray
    
    // MARK: - Helper Initializer for Light/Dark Colors
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor(light: UIColor(light), dark: UIColor(dark)))
    }
}

// MARK: - UIColor Extension for Light/Dark Mode
extension UIColor {
    convenience init(light: UIColor, dark: UIColor) {
        self.init { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return dark
            case .light, .unspecified:
                return light
            @unknown default:
                return light
            }
        }
    }
}

// MARK: - ShapeStyle Extensions
// This makes colors available for .foregroundStyle() modifier
extension ShapeStyle where Self == Color {
    // Backgrounds
    static var softCream: Color { .softCream }
    static var cardBackground: Color { .cardBackground }
    
    // Warm earth tones
    static var terracotta: Color { .terracotta }
    static var terracottaLight: Color { .terracottaLight }
    static var terracottaDark: Color { .terracottaDark }
    
    static var sageGreen: Color { .sageGreen }
    static var sageGreenLight: Color { .sageGreenLight }
    static var sageGreenDark: Color { .sageGreenDark }
    
    static var warmBrown: Color { .warmBrown }
    static var warmBrownLight: Color { .warmBrownLight }
    
    // Aging colors
    static var recentWarm: Color { .recentWarm }
    static var recentVibrant: Color { .recentVibrant }
    static var fadingWarm: Color { .fadingWarm }  // ← Make sure this line exists!
    static var fadingNeutral: Color { .fadingNeutral }
    static var oldCool: Color { .oldCool }
    static var oldFaded: Color { .oldFaded }
}

// MARK: - Typography
extension Font {
    // Rounded variants for softer feel
    static let keetTitle = Font.system(.title, design: .rounded, weight: .semibold)
    static let keetHeadline = Font.system(.headline, design: .rounded, weight: .medium)
    static let keetBody = Font.system(.body, design: .default)
    static let keetCaption = Font.system(.caption, design: .default, weight: .regular)
    static let keetCaption2 = Font.system(.caption2, design: .default, weight: .regular)
}

// MARK: - Shadows
extension View {
    func keetShadow(intensity: ShadowIntensity = .medium) -> some View {
        self.shadow(
            color: Color.black.opacity(intensity.opacity),
            radius: intensity.radius,
            x: 0,
            y: intensity.yOffset
        )
    }
}

enum ShadowIntensity {
    case light, medium, strong
    
    var opacity: Double {
        switch self {
        case .light: return 0.08
        case .medium: return 0.12
        case .strong: return 0.18
        }
    }
    
    var radius: CGFloat {
        switch self {
        case .light: return 4
        case .medium: return 8
        case .strong: return 12
        }
    }
    
    var yOffset: CGFloat {
        switch self {
        case .light: return 2
        case .medium: return 4
        case .strong: return 6
        }
    }
}

// MARK: - Corner Radius
extension CGFloat {
    static let keetCornerSmall: CGFloat = 12
    static let keetCornerMedium: CGFloat = 16
    static let keetCornerLarge: CGFloat = 24
}

// MARK: - Visual Aging
extension Contact {
    /// Returns a color that shifts from warm/vibrant to cool/faded based on days since contact
    var agingColor: Color {
        let daysSince = Calendar.current.dateComponents([.day], from: lastContacted, to: Date()).day ?? 0
        
        switch daysSince {
        case 0...1:
            return .recentWarm          // Vibrant warm red-orange
        case 2...3:
            return .recentVibrant       // Warm terracotta
        case 4...7:
            return .fadingWarm          // Cooling terracotta
        case 8...14:
            return .fadingNeutral       // Warm beige
        case 15...30:
            return .oldCool             // Cool blue-gray
        default:
            return .oldFaded            // Very desaturated gray
        }
    }
    
    /// Returns saturation level that decreases as contact ages (1.0 = full color, 0.0 = grayscale)
    var agingSaturation: Double {
        let daysSince = Calendar.current.dateComponents([.day], from: lastContacted, to: Date()).day ?? 0

        switch daysSince {
        case 0...1:
            return 1.1
        case 2...3:
            return 0.95
        case 4...7:
            return 0.90
        case 8...14:
            return 0.80
        case 15...30:
            return 0.70
        case 30...60:
            return 0.50
        default:
            return 0.30
        }
    }
    
    var coolOverlayOpacity: Double {
        let daysSince = Calendar.current.dateComponents([.day], from: lastContacted, to: Date()).day ?? 0
        
        switch daysSince {
        case 0...1:
            return 0
        case 2...3:
            return 0.1
        case 4...7:
            return 0.2
        case 8...14:
            return 0.3
        case 15...30:
            return 0.4
        case 30...60:
            return 0.55
        default:
            return 0.70
        }
    }
    
    /// Frost intensity for border effect (0.0 = no frost, 1.0 = maximum frost)
    /// Only applies to contacts that are getting cold (15+ days)
    var frostIntensity: Double {
        let daysSince = Calendar.current.dateComponents([.day], from: lastContacted, to: Date()).day ?? 0
        
        switch daysSince {
        case 0...14:
            return 0.0  // No frost for recent contacts
        case 15...21:
            return 0.3  // Light frost starting
        case 22...30:
            return 0.5  // Medium frost
        case 31...45:
            return 0.7  // Heavy frost
        default:
            return 1.0  // Maximum frost for very old contacts
        }
    }
    
    /// Determines text color contrast based on aging
    var agingTextColor: Color {
        let daysSince = Calendar.current.dateComponents([.day], from: lastContacted, to: Date()).day ?? 0
        return daysSince > 14 ? Color.primary : Color.white
    }
}

// MARK: - Spacing
extension CGFloat {
    static let keetSpacingXS: CGFloat = 4
    static let keetSpacingS: CGFloat = 8
    static let keetSpacingM: CGFloat = 12
    static let keetSpacingL: CGFloat = 16
    static let keetSpacingXL: CGFloat = 24
    static let keetSpacingXXL: CGFloat = 32
}
// MARK: - Animations
extension Animation {
    /// Standard spring animation with organic feel
    static let keetSpring = Animation.spring(response: 0.5, dampingFraction: 0.7)
    
    /// Quick spring for subtle interactions
    static let keetSpringQuick = Animation.spring(response: 0.3, dampingFraction: 0.7)
    
    /// Slow spring for major transitions
    static let keetSpringSlow = Animation.spring(response: 0.8, dampingFraction: 0.7)
}

// MARK: - Reusable Component Styles
/// Custom ViewModifier for card styling (like a React component with styled-components)
struct KeetCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: .keetCornerMedium))
            .keetShadow(intensity: .medium)
    }
}

extension View {
    /// Apply standard Keet card styling
    func keetCardStyle() -> some View {
        modifier(KeetCardStyle())
    }
}

/// Button style matching Keet design system
struct KeetButtonStyle: ButtonStyle {
    var variant: ButtonVariant = .primary
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.keetHeadline)
            .foregroundStyle(variant.foregroundColor)
            .padding(.horizontal, .keetSpacingL)
            .padding(.vertical, .keetSpacingM)
            .background(variant.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: .keetCornerMedium))
            .keetShadow(intensity: configuration.isPressed ? .light : .medium)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.keetSpringQuick, value: configuration.isPressed)
    }
    
    enum ButtonVariant {
        case primary, secondary, tertiary
        
        var backgroundColor: Color {
            switch self {
            case .primary: return .terracotta
            case .secondary: return .sageGreen
            case .tertiary: return .softCream
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary, .secondary: return .white
            case .tertiary: return .warmBrown
            }
        }
    }
}

extension View {
    /// Apply Keet button style
    func keetButton(variant: KeetButtonStyle.ButtonVariant = .primary) -> some View {
        buttonStyle(KeetButtonStyle(variant: variant))
    }
}

