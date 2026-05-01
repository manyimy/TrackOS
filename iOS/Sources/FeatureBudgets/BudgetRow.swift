import SwiftUI
import Domain
import DesignSystem

public struct BudgetRow: View {
    @Environment(\.theme) private var theme
    private let budget: BudgetDTO

    public init(budget: BudgetDTO) {
        self.budget = budget
    }

    private var statusColor: Color {
        if budget.isExceeded { return theme.color.danger }
        if budget.percentUsed > 0.8 { return theme.color.warn }
        return theme.color.good
    }

    public var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(budget.categoryName)
                        .font(theme.font.label(15))
                        .foregroundStyle(theme.color.text)
                    Text(budget.period.rawValue.capitalized)
                        .font(theme.font.body(12))
                        .foregroundStyle(theme.color.textTertiary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 3) {
                    HStack(alignment: .firstTextBaseline, spacing: 3) {
                        Text(budget.currency.format(budget.spent))
                            .font(theme.font.mono(15))
                            .foregroundStyle(budget.isExceeded ? theme.color.danger : theme.color.text)
                        Text("/ \(budget.currency.format(budget.limit))")
                            .font(theme.font.body(12))
                            .foregroundStyle(theme.color.textTertiary)
                    }

                    // Status badge
                    Text(budget.isExceeded ? "Over budget" : "\(Int(budget.percentUsed * 100))% used")
                        .font(theme.font.label(11))
                        .foregroundStyle(statusColor)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(statusColor.opacity(0.12))
                        .clipShape(Capsule())
                }
            }

            ProgressBar(progress: budget.percentUsed, color: budget.isExceeded ? theme.color.danger : statusColor)
        }
        .padding(theme.space.lg)
        .surface(theme)
    }
}
