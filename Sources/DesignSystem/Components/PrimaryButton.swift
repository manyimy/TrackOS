import SwiftUI

public struct PrimaryButton: View {
    @Environment(\.theme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    private let title: LocalizedStringKey
    private let icon: String?
    private let isLoading: Bool
    private let action: () -> Void

    public init(
        _ title: LocalizedStringKey,
        icon: String? = nil,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isLoading = isLoading
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: theme.space.sm) {
                if isLoading {
                    ProgressView()
                        .tint(theme.color.accentInk)
                        .controlSize(.small)
                } else if let icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .font(theme.font.label(16))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, theme.space.lg)
            .background(isEnabled ? theme.color.accent : theme.color.surfaceTertiary)
            .foregroundStyle(isEnabled ? theme.color.accentInk : theme.color.textTertiary)
            .clipShape(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous))
        }
        .disabled(isLoading)
    }
}
