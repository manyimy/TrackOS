import CoreGraphics

public struct SpaceTokens: Sendable {
    public let xs:   CGFloat = 4
    public let sm:   CGFloat = 8
    public let md:   CGFloat = 12
    public let lg:   CGFloat = 16
    public let xl:   CGFloat = 20
    public let xxl:  CGFloat = 28
    public let xxxl: CGFloat = 40

    public static let standard = SpaceTokens()
}
