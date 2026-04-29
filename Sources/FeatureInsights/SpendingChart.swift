import SwiftUI
import Domain
import DesignSystem

public struct SpendingChart: View {
    @Environment(\.theme) private var theme
    private let data: [DailySpend]

    public init(data: [DailySpend]) {
        self.data = data
    }

    private var maxValue: Decimal {
        data.map(\.amount).max() ?? 1
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.space.md) {
            Text("7-Day Trend")
                .font(theme.font.title(17))
                .foregroundStyle(theme.color.text)

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(data) { day in
                    bar(day)
                }
            }
            .frame(height: 120)

            HStack {
                ForEach(data) { day in
                    Text(day.date, format: .dateTime.weekday(.narrow))
                        .font(theme.font.body(11))
                        .foregroundStyle(theme.color.textTertiary)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(theme.space.xl)
        .surface(theme)
    }

    private func bar(_ day: DailySpend) -> some View {
        let ratio = maxValue > 0
            ? CGFloat(truncating: (day.amount / maxValue) as NSDecimalNumber)
            : 0
        let isToday = Calendar.current.isDateInToday(day.date)

        return VStack {
            Spacer()
            RoundedRectangle(cornerRadius: theme.radius.sm, style: .continuous)
                .fill(isToday ? theme.color.accent : theme.color.surfaceSecondary)
                .frame(height: max(4, 100 * ratio))
        }
        .frame(maxWidth: .infinity)
    }
}
