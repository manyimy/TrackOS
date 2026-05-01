import SwiftUI

public struct Chip: View {
    @Environment(\.theme) private var theme

    private let label: String
    private let icon: String?
    private let color: Color?
    private let isSelected: Bool
    private let action: () -> Void

    public init(
        _ label: String,
        icon: String? = nil,
        color: Color? = nil,
        isSelected: Bool = false,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.icon = icon
        self.color = color
        self.isSelected = isSelected
        self.action = action
    }

    private var tint: Color { color ?? theme.color.accent }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .medium))
                }
                Text(label)
                    .font(theme.font.label(13))
            }
            .padding(.horizontal, theme.space.md)
            .padding(.vertical, theme.space.sm - 2)
            .background(isSelected ? tint.opacity(0.18) : theme.color.surfaceSecondary)
            .foregroundStyle(isSelected ? tint : theme.color.textSecondary)
            .clipShape(Capsule())
            .overlay(Capsule().strokeBorder(isSelected ? tint : Color.clear, lineWidth: 1.5))
        }
        .buttonStyle(.plain)
    }
}
