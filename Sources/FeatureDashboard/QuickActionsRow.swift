import SwiftUI
import DesignSystem

public struct QuickActionsRow: View {
    @Environment(\.theme) private var theme

    private let onAddExpense: () -> Void
    private let onScanReceipt: () -> Void

    public init(onAddExpense: @escaping () -> Void, onScanReceipt: @escaping () -> Void) {
        self.onAddExpense = onAddExpense
        self.onScanReceipt = onScanReceipt
    }

    public var body: some View {
        HStack(spacing: theme.space.md) {
            actionButton(icon: "plus", label: "Add Expense", action: onAddExpense)
            actionButton(icon: "doc.viewfinder", label: "Scan Receipt", action: onScanReceipt)
        }
    }

    private func actionButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: theme.space.sm) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                Text(label)
                    .font(theme.font.label(14))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, theme.space.md)
            .background(theme.color.surfaceSecondary)
            .foregroundStyle(theme.color.text)
            .clipShape(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                    .strokeBorder(theme.color.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
