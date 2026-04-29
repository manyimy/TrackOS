import SwiftUI
import Domain
import DesignSystem

public struct BudgetRow: View {
    @Environment(\.theme) private var theme
    private let budget: BudgetDTO

    public init(budget: BudgetDTO) {
        self.budget = budget
    }

    public var body: some View {
        VStack(spacing: theme.space.md) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(budget.categoryName)
                        .font(theme.font.label(15))
                        .foregroundStyle(theme.color.text)
                    Text(budget.period.rawValue.capitalized)
                        .font(theme.font.body(12))
                        .foregroundStyle(theme.color.textSecondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 3) {
                    Text(budget.currency.format(budget.spent))
                        .font(theme.font.mono(15))
                        .foregroundStyle(budget.isExceeded ? theme.color.danger : theme.color.text)
                    Text("of \(budget.currency.format(budget.limit))")
                        .font(theme.font.body(12))
                        .foregroundStyle(theme.color.textSecondary)
                }
            }

            ProgressBar(
                progress: budget.percentUsed,
                color: budget.isExceeded ? theme.color.danger : nil
            )
        }
        .padding(theme.space.lg)
        .surface(theme)
    }
}
