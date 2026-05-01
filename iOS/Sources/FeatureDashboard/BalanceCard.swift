import SwiftUI
import Domain
import DesignSystem

public struct BalanceCard: View {
    @Environment(\.theme) private var theme
    private let total: Decimal
    private let currency: CurrencyCode
    private let period: DashboardModel.Period
    private let expenseCount: Int

    public init(
        total: Decimal,
        currency: CurrencyCode,
        period: DashboardModel.Period,
        expenseCount: Int
    ) {
        self.total = total
        self.currency = currency
        self.period = period
        self.expenseCount = expenseCount
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            // Background
            RoundedRectangle(cornerRadius: theme.radius.xl, style: .continuous)
                .fill(theme.color.accent)

            // Decorative circles
            Circle().fill(theme.color.accentInk.opacity(0.06))
                .frame(width: 240).offset(x: 100, y: -80)
            Circle().fill(theme.color.accentInk.opacity(0.04))
                .frame(width: 160).offset(x: -40, y: 90)

            VStack(alignment: .leading, spacing: theme.space.sm) {
                HStack {
                    Text("Total Spent")
                        .font(theme.font.label(13))
                        .foregroundStyle(theme.color.accentInk.opacity(0.7))
                    Spacer()
                    Label("\(expenseCount)", systemImage: "creditcard")
                        .font(theme.font.label(12))
                        .foregroundStyle(theme.color.accentInk.opacity(0.8))
                        .padding(.horizontal, theme.space.md)
                        .padding(.vertical, 5)
                        .background(theme.color.accentInk.opacity(0.15))
                        .clipShape(Capsule())
                }

                Text(currency.format(total))
                    .font(theme.font.display(40))
                    .foregroundStyle(theme.color.accentInk)

                Text("This \(period.rawValue.lowercased())")
                    .font(theme.font.body(13))
                    .foregroundStyle(theme.color.accentInk.opacity(0.6))
            }
            .padding(theme.space.xl)
        }
        .frame(height: 162)
    }
}
