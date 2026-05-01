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

    private var sorted: [CategorySpend] {
        items.sorted { $0.amount > $1.amount }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.space.md) {
            Text("By Category")
                .font(theme.font.title(17))
                .foregroundStyle(theme.color.text)

            VStack(spacing: 0) {
                ForEach(Array(sorted.enumerated()), id: \.element.id) { idx, item in
                    categoryRow(item)
                    if idx < sorted.count - 1 {
                        Rectangle()
                            .fill(theme.color.divider)
                            .frame(height: 1)
                            .padding(.leading, 52)
                    }
                }
            }
        }
        .padding(theme.space.xl)
        .surface(theme)
    }

    private func categoryRow(_ item: CategorySpend) -> some View {
        let pct = totalSpent > 0
            ? Double(truncating: (item.amount / totalSpent) as NSDecimalNumber)
            : 0.0
        let pctText = String(format: "%.0f%%", pct * 100)

        return HStack(spacing: theme.space.md) {
            CategoryDot(colorHex: item.categoryColor, symbolName: item.categorySymbol, size: 36)

            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(item.categoryName)
                        .font(theme.font.label(14))
                        .foregroundStyle(theme.color.text)
                    Spacer()
                    Text(currency.format(item.amount))
                        .font(theme.font.mono(13))
                        .foregroundStyle(theme.color.text)
                }
                HStack(spacing: theme.space.sm) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(theme.color.surfaceTertiary)
                                .frame(height: 5)
                            Capsule()
                                .fill(Color(hex: item.categoryColor).opacity(0.8))
                                .frame(width: geo.size.width * pct, height: 5)
                        }
                    }
                    .frame(height: 5)
                    Text(pctText)
                        .font(theme.font.mono(11))
                        .foregroundStyle(theme.color.textTertiary)
                        .frame(width: 32, alignment: .trailing)
                }
            }
        }
        .padding(.vertical, theme.space.md)
    }
}
