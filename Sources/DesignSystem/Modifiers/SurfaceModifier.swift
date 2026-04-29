import SwiftUI

public extension View {
    /// Applies the correct surface treatment: border on dark, shadow on light.
    func surface(_ theme: Theme, radius: CGFloat? = nil) -> some View {
        let r = radius ?? theme.radius.card
        return self
            .background(theme.color.surface)
            .clipShape(RoundedRectangle(cornerRadius: r, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: r, style: .continuous)
                    .strokeBorder(theme.color.border, lineWidth: 1)
            )
            .shadow(
                color: theme.isDark ? .clear : Color.black.opacity(0.07),
                radius: theme.isDark ? 0 : 12, y: theme.isDark ? 0 : 4
            )
    }
}
