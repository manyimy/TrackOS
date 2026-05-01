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
                    .padding(.vertical, 13)
                if idx < min(7, expenses.count - 1) {
                    Rectangle()
                        .fill(theme.color.divider)
                        .frame(height: 1)
                        .padding(.leading, 60)
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
                colorHex: expense.categoryColor ?? "#56566A",
                symbolName: expense.categorySymbol ?? "questionmark"
            )
            .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(expense.merchant)
                    .font(theme.font.label(15))
                    .foregroundStyle(theme.color.text)
                    .lineLimit(1)
                Text(relativeTime(expense.occurredAt))
                    .font(theme.font.body(12))
                    .foregroundStyle(theme.color.textTertiary)
            }

            Spacer(minLength: theme.space.sm)

            Text(expense.currency.format(expense.amount))
                .font(theme.font.mono(15))
                .foregroundStyle(theme.color.text)
        }
    }

    private func relativeTime(_ date: Date) -> String {
        let cal = Calendar.current
        let time = date.formatted(.dateTime.hour().minute())
        if cal.isDateInToday(date)     { return time }
        if cal.isDateInYesterday(date) { return "Yesterday · \(time)" }
        return date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day())
    }
}
