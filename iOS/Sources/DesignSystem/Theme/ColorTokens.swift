import SwiftUI

public struct ColorTokens: Sendable {
    public let bg: Color
    public let surface: Color
    public let surfaceSecondary: Color
    public let surfaceTertiary: Color
    public let border: Color
    public let divider: Color
    public let text: Color
    public let textSecondary: Color
    public let textTertiary: Color
    public let accent: Color
    public let accentInk: Color
    public let good: Color
    public let warn: Color
    public let danger: Color

    public static let dark = ColorTokens(
        bg:               Color(hex: "#0A0A0B"),
        surface:          Color(hex: "#111114"),
        surfaceSecondary: Color(hex: "#18181D"),
        surfaceTertiary:  Color(hex: "#232329"),
        border:           Color(hex: "#26262C"),
        divider:          Color(hex: "#26262C"),
        text:             Color(hex: "#FAFAFA"),
        textSecondary:    Color(hex: "#A1A1AA"),
        textTertiary:     Color(hex: "#6B6B73"),
        accent:           Color(hex: "#B6FF3D"),
        accentInk:        Color(hex: "#0A0A0B"),
        good:             Color(hex: "#5EE6A4"),
        warn:             Color(hex: "#FF9F45"),
        danger:           Color(hex: "#FF5C5C")
    )

    public static let light = ColorTokens(
        bg:               Color(hex: "#FAFAF7"),
        surface:          Color(hex: "#FFFFFF"),
        surfaceSecondary: Color(hex: "#F4F4F0"),
        surfaceTertiary:  Color(hex: "#EDEDE8"),
        border:           Color.clear,
        divider:          Color.black.opacity(0.06),
        text:             Color(hex: "#18181C"),
        textSecondary:    Color(hex: "#5A5A60"),
        textTertiary:     Color(hex: "#9C9CA3"),
        accent:           Color(hex: "#5BA800"),
        accentInk:        Color(hex: "#FFFFFF"),
        good:             Color(hex: "#1FA86A"),
        warn:             Color(hex: "#E07820"),
        danger:           Color(hex: "#DC3838")
    )
}

extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >>  8) & 0xFF) / 255
        let b = Double( rgb        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
