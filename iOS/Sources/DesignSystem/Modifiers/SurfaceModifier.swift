import SwiftUI

public extension View {
    func surface(_ theme: Theme, radius: CGFloat? = nil) -> some View {
        let r = radius ?? theme.radius.card
        return self
            .background(theme.color.surface)
            .clipShape(RoundedRectangle(cornerRadius: r, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: r, style: .continuous)
                    .strokeBorder(
                        theme.isDark
                            ? LinearGradient(
                                colors: [Color.white.opacity(0.08), Color.white.opacity(0.03)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                              )
                            : LinearGradient(colors: [.clear], startPoint: .top, endPoint: .bottom),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: theme.isDark ? .clear : Color.black.opacity(0.06),
                radius: theme.isDark ? 0 : 16, y: theme.isDark ? 0 : 6
            )
    }
}
