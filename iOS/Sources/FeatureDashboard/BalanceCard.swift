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
            // Base gradient
            RoundedRectangle(cornerRadius: theme.radius.xl, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#CAFF58"), Color(hex: "#94D40E")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Spotlight highlight top-right
            Circle()
                .fill(Color.white.opacity(0.18))
                .frame(width: 220)
                .offset(x: 160, y: -100)
                .blur(radius: 40)

            // Decorative orbs
            Circle()
                .fill(theme.color.accentInk.opacity(0.07))
                .frame(width: 180)
                .offset(x: -30, y: 80)
            Circle()
                .fill(Color.white.opacity(0.06))
                .frame(width: 100)
                .offset(x: 250, y: 60)

            VStack(alignment: .leading, spacing: theme.space.sm) {
                HStack(alignment: .center) {
                    Label {
                        Text("Total Spent")
                            .font(theme.font.label(12))
                    } icon: {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 11))
                    }
                    .foregroundStyle(theme.color.accentInk.opacity(0.6))

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "creditcard.fill")
                            .font(.system(size: 10, weight: .semibold))
                        Text("\(expenseCount)")
                            .font(theme.font.label(12))
                    }
                    .foregroundStyle(theme.color.accentInk.opacity(0.75))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(theme.color.accentInk.opacity(0.12))
                    .clipShape(Capsule())
                }

                Spacer()

                Text(currency.format(total))
                    .font(theme.font.display(42))
                    .foregroundStyle(theme.color.accentInk)
                    .contentTransition(.numericText())

                Text("this \(period.rawValue.lowercased())")
                    .font(theme.font.body(13))
                    .foregroundStyle(theme.color.accentInk.opacity(0.55))
            }
            .padding(theme.space.xl)
        }
        .frame(height: 170)
    }
}
