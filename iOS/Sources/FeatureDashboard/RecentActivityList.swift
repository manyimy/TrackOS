import SwiftUI
import Domain
import DesignSystem

public struct RecentActivityList: View {
    @Environment(\.theme) private var theme
    private let expenses: [ExpenseDTO]

    public init(expenses: [ExpenseDTO]) {
        self.expenses = expenses
    }

    public var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(expenses.prefix(8).enumerated()), id: \.element.id) { idx, expense in
                ExpenseRow(expense: expense)
                    .padding(.horizontal, theme.space.lg)
                    .padding(.vertical, theme.space.md)
                if idx < min(7, expenses.count - 1) {
                    Divider()
                        .background(theme.color.divider)
                        .padding(.leading, 64)
                }
            }
        }
        .surface(theme)
    }
}

public struct ExpenseRow: View {
    @Environment(\.theme) private var theme
    private let expense: ExpenseDTO

    public init(expense: ExpenseDTO) {
        self.expense = expense
    }

    public var body: some View {
        HStack(spacing: theme.space.md) {
            CategoryDot(
                colorHex: expense.categoryColor ?? "#A1A1AA",
                symbolName: expense.categorySymbol ?? "questionmark.circle"
            )

            VStack(alignment: .leading, spacing: 3) {
                Text(expense.merchant)
                    .font(theme.font.label(15))
                    .foregroundStyle(theme.color.text)
                    .lineLimit(1)
                Text(expense.occurredAt, format: .dateTime.month(.abbreviated).day().hour().minute())
                    .font(theme.font.body(12))
                    .foregroundStyle(theme.color.textSecondary)
            }

            Spacer()

            Text(expense.currency.format(expense.amount))
                .font(theme.font.mono(15))
                .foregroundStyle(theme.color.text)
        }
    }
}
