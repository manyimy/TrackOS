import SwiftUI

public struct FontTokens: Sendable {
    public func display(_ size: CGFloat) -> Font {
        .system(size: size, weight: .heavy).monospacedDigit()
    }
    public func title(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold)
    }
    public func body(_ size: CGFloat) -> Font {
        .system(size: size, weight: .regular)
    }
    public func label(_ size: CGFloat) -> Font {
        .system(size: size, weight: .medium)
    }
    public func mono(_ size: CGFloat) -> Font {
        .system(size: size, weight: .medium, design: .monospaced)
    }

    public static let standard = FontTokens()
}
