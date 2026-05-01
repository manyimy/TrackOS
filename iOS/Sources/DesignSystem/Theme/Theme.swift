import SwiftUI

public struct Theme: Sendable {
    public let color: ColorTokens
    public let space: SpaceTokens
    public let radius: RadiusTokens
    public let font: FontTokens

    public static let dark  = Theme(color: .dark,  space: .standard, radius: .standard, font: .standard)
    public static let light = Theme(color: .light, space: .standard, radius: .standard, font: .standard)

    // MARK: - Dark-mode helpers

    /// `true` when this theme's bg is dark.
    public var isDark: Bool { color.bg == ColorTokens.dark.bg }

    /// Shadow style — only used in light theme.
    public func shadow(radius: CGFloat = 8, y: CGFloat = 4) -> some View {
        EmptyView() // used as a namespace; see View+Theme for the modifier
    }
}

// MARK: - Environment key

private struct ThemeKey: EnvironmentKey {
    static let defaultValue: Theme = .dark
}

public extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}
