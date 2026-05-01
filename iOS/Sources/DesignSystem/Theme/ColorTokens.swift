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
        bg:               Color(hex: "#09090C"),
        surface:          Color(hex: "#0F0F14"),
        surfaceSecondary: Color(hex: "#161620"),
        surfaceTertiary:  Color(hex: "#1E1E2A"),
        border:           Color(hex: "#2A2A38"),
        divider:          Color(hex: "#1E1E28"),
        text:             Color(hex: "#F0F0F8"),
        textSecondary:    Color(hex: "#9898B0"),
        textTertiary:     Color(hex: "#56566A"),
        accent:           Color(hex: "#B6FF3D"),
        accentInk:        Color(hex: "#0A1400"),
        good:             Color(hex: "#4ADE80"),
        warn:             Color(hex: "#FB923C"),
        danger:           Color(hex: "#F87171")
    )

    public static let light = ColorTokens(
        bg:               Color(hex: "#F5F5F2"),
        surface:          Color(hex: "#FFFFFF"),
        surfaceSecondary: Color(hex: "#EFEFEB"),
        surfaceTertiary:  Color(hex: "#E6E6E2"),
        border:           Color.clear,
        divider:          Color.black.opacity(0.06),
        text:             Color(hex: "#16161A"),
        textSecondary:    Color(hex: "#58586A"),
        textTertiary:     Color(hex: "#9A9AAA"),
        accent:           Color(hex: "#5BA800"),
        accentInk:        Color(hex: "#FFFFFF"),
        good:             Color(hex: "#16A34A"),
        warn:             Color(hex: "#D97706"),
        danger:           Color(hex: "#DC2626")
    )
}

extension Color {
    public init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >>  8) & 0xFF) / 255
        let b = Double( rgb        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
