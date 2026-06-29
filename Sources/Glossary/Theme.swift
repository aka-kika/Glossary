import SwiftUI

/// KIKA brand palette (dark theme) — see design spec §6.
enum Theme {
    static let bg      = Color(hex: 0x2C2D2F)
    static let surface = Color(hex: 0x202024)
    static let fg      = Color(hex: 0xE7E5E0)
    static let fg2     = Color(hex: 0xB9B8B3)
    static let fg3     = Color(hex: 0x8C8D8F)
    static let accent  = Color(hex: 0x6D80A6)
    static let line    = Color(hex: 0xE7E5E0).opacity(0.10)
    static let line2   = Color(hex: 0xE7E5E0).opacity(0.05)

    /// Brand-derived disclosure-block header accents.
    static let whatItIsAccent = Color(hex: 0x6D80A6)  // slate blue
    static let analogyAccent  = Color(hex: 0xB9B8B3)  // sand
    static let whyAccent      = Color(hex: 0xFF8A80)  // coral
    static let exampleAccent  = Color(hex: 0x9B8FA6)  // dusty lilac

    static let cornerRadius: CGFloat = 16
    static let panelWidth: CGFloat = 640
    static let panelHeight: CGFloat = 440
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
