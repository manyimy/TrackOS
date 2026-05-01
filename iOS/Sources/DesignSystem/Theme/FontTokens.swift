import SwiftUI

public struct FontTokens: Sendable {
    // Rounded design throughout — warmer and more premium than default
    public func display(_ size: CGFloat) -> Font {
        .system(size: size, weight: .black, design: .rounded)
    }
    public func title(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
    public func body(_ size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .rounded)
    }
    public func label(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }
    public func mono(_ size: CGFloat) -> Font {
        .system(size: size, weight: .medium, design: .monospaced)
    }

    public static let standard = FontTokens()
}
