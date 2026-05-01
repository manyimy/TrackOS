import CoreGraphics

public struct RadiusTokens: Sendable {
    public let sm:   CGFloat = 8
    public let md:   CGFloat = 12
    public let lg:   CGFloat = 16
    public let xl:   CGFloat = 20
    public let card: CGFloat = 18
    public let pill: CGFloat = 100

    public static let standard = RadiusTokens()
}
