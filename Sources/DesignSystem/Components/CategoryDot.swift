import SwiftUI

public struct CategoryDot: View {
    @Environment(\.theme) private var theme
    private let colorHex: String
    private let symbolName: String
    private let size: CGFloat

    public init(colorHex: String, symbolName: String, size: CGFloat = 36) {
        self.colorHex = colorHex
        self.symbolName = symbolName
        self.size = size
    }

    public var body: some View {
        let tint = Color(hex: colorHex)
        ZStack {
            Circle()
                .fill(tint.opacity(0.18))
                .frame(width: size, height: size)
            Image(systemName: symbolName)
                .font(.system(size: size * 0.44, weight: .medium))
                .foregroundStyle(tint)
        }
    }
}
