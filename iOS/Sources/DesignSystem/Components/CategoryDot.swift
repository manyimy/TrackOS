import SwiftUI

public struct CategoryDot: View {
    private let colorHex: String
    private let symbolName: String
    private let size: CGFloat

    public init(colorHex: String, symbolName: String, size: CGFloat = 38) {
        self.colorHex = colorHex
        self.symbolName = symbolName
        self.size = size
    }

    public var body: some View {
        let tint = Color(hex: colorHex)
        ZStack {
            Circle()
                .fill(tint.opacity(0.15))
                .frame(width: size, height: size)
            Circle()
                .strokeBorder(tint.opacity(0.2), lineWidth: 1)
                .frame(width: size, height: size)
            Image(systemName: symbolName)
                .font(.system(size: size * 0.42, weight: .semibold))
                .foregroundStyle(tint)
        }
    }
}
