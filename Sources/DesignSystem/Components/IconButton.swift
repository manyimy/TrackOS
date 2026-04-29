import SwiftUI

public struct IconButton: View {
    @Environment(\.theme) private var theme

    private let icon: String
    private let label: LocalizedStringKey
    private let action: () -> Void

    public init(_ icon: String, label: LocalizedStringKey = "", action: @escaping () -> Void) {
        self.icon = icon
        self.label = label
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(theme.color.text)
                .frame(width: 40, height: 40)
                .background(theme.color.surfaceSecondary)
                .clipShape(Circle())
        }
        .accessibilityLabel(label)
    }
}
