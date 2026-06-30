import SwiftUI
import AppKit

/// KIKA brand palette. Colors are dynamic — they resolve to the dark or light
/// KIKA tokens based on the hosting window's appearance (see design spec §6).
enum Theme {
    static let cornerRadius: CGFloat = 16

    static let bg      = dynamic(light: 0xE8E7E2, dark: 0x2C2D2F)
    static let surface = dynamic(light: 0xF3F2ED, dark: 0x202024)
    static let fg      = dynamic(light: 0x2C2D2F, dark: 0xE7E5E0)
    static let fg2     = dynamic(light: 0x404040, dark: 0xB9B8B3)
    static let fg3     = dynamic(light: 0x8C8C8C, dark: 0x8C8D8F)
    static let accent  = Color(hex: 0x6D80A6)

    static let line  = dynamicAlpha(light: (0x0D0D0D, 0.14), dark: (0xE7E5E0, 0.10))
    static let line2 = dynamicAlpha(light: (0x0D0D0D, 0.05), dark: (0xE7E5E0, 0.05))

    /// Brand-derived disclosure-block header accents (same in both modes).
    static let whatItIsAccent = Color(hex: 0x6D80A6)  // slate blue
    static let analogyAccent  = Color(hex: 0xB9B8B3)  // sand
    static let whyAccent      = Color(hex: 0xFF8A80)  // coral
    static let exampleAccent  = Color(hex: 0x9B8FA6)  // dusty lilac

    // MARK: - Dynamic helpers

    private static func dynamic(light: UInt32, dark: UInt32) -> Color {
        Color(nsColor: NSColor(name: nil) { ap in
            isDark(ap) ? NSColor(hex: dark) : NSColor(hex: light)
        })
    }

    private static func dynamicAlpha(light: (UInt32, CGFloat), dark: (UInt32, CGFloat)) -> Color {
        Color(nsColor: NSColor(name: nil) { ap in
            isDark(ap)
                ? NSColor(hex: dark.0, alpha: dark.1)
                : NSColor(hex: light.0, alpha: light.1)
        })
    }

    static func isDark(_ ap: NSAppearance) -> Bool {
        ap.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red:   Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue:  Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}

extension NSColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        self.init(
            srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
            green:   CGFloat((hex >> 8) & 0xFF) / 255,
            blue:    CGFloat(hex & 0xFF) / 255,
            alpha:   alpha
        )
    }
}
