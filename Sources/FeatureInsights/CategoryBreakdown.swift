import SwiftUI
import Domain
import DesignSystem

public struct CategoryBreakdown: View {
    @Environment(\.theme) private var theme
    private let items: [CategorySpend]
    private let currency: CurrencyCode

    public init(items: [CategorySpend], currency: CurrencyCode) {
        self.items = items
        self.currency = currency
    }

    private var totalSpent: Decimal {
        items.reduce(.zero) { $0 + $1.amount }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.space.md) {
            Text("By Category")
                .font(theme.font.title(17))
                .foregroundStyle(theme.color.text)

            VStack(spacing: 0) {
                ForEach(Array(items.sorted { $0.amount > $1.amount }.enumerated()), id: \.element.id) { idx, item in
                    categoryRow(item)
                    if idx < items.count - 1 {
                        Divider()
                            .background(theme.color.divider)
                            .padding(.leading, 48)
                    }
                }
            }
        }
        .padding(theme.space.xl)
        .surface(theme)
    }

    private func categoryRow(_ item: CategorySpend) -> some View {
        let pct = totalSpent > 0
            ? Double(truncating: (item.amount / totalSpent * 100) as NSDecimalNumber) / 100.0
            : 0.0

        return HStack(spacing: theme.space.md) {
            CategoryDot(
                colorHex: item.categoryColor,
                symbolName: item.categorySymbol
            )

            VStack(alignment: .leading, spacing: 3) {
                Text(item.categoryName)
                    .font(theme.font.label(14))
                    .foregroundStyle(theme.color.text)
                ProgressBar(progress: pct)
                    .frame(height: 4)
            }

            Spacer()

            Text(currency.format(item.amount))
                .font(theme.font.mono(13))
                .foregroundStyle(theme.color.text)
        }
        .padding(.vertical, theme.space.md)
    }
}
