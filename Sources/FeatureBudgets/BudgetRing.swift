import SwiftUI
import Domain
import DesignSystem

public struct BudgetRing: View {
    @Environment(\.theme) private var theme
    private let budget: BudgetDTO
    private let size: CGFloat

    public init(budget: BudgetDTO, size: CGFloat = 80) {
        self.budget = budget
        self.size = size
    }

    public var body: some View {
        ZStack {
            ProgressRing(
                progress: budget.percentUsed,
                color: ringColor,
                lineWidth: 8,
                size: size
            )

            VStack(spacing: 2) {
                Text("\(Int(budget.percentUsed * 100))%")
                    .font(theme.font.mono(14))
                    .foregroundStyle(theme.color.text)
                Text(budget.period.rawValue.prefix(1))
                    .font(theme.font.body(10))
                    .foregroundStyle(theme.color.textTertiary)
            }
        }
        .frame(width: size, height: size)
    }

    private var ringColor: Color {
        if budget.isExceeded { return theme.color.danger }
        if budget.percentUsed > 0.8 { return theme.color.warn }
        return theme.color.accent
    }
}
