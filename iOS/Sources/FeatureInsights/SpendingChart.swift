import SwiftUI
import Domain
import DesignSystem

public struct SpendingChart: View {
    @Environment(\.theme) private var theme
    private let data: [DailySpend]
    @State private var appeared = false

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

            HStack(alignment: .bottom, spacing: 6) {
                ForEach(Array(data.enumerated()), id: \.element.id) { idx, day in
                    bar(day, index: idx)
                }
            }
            .frame(height: 120)

            HStack(spacing: 6) {
                ForEach(data) { day in
                    Text(day.date, format: .dateTime.weekday(.narrow))
                        .font(theme.font.body(11))
                        .foregroundStyle(
                            Calendar.current.isDateInToday(day.date)
                                ? theme.color.accent : theme.color.textTertiary
                        )
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(theme.space.xl)
        .surface(theme)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                appeared = true
            }
        }
    }

    private func bar(_ day: DailySpend, index: Int) -> some View {
        let ratio = maxValue > 0
            ? CGFloat(truncating: (day.amount / maxValue) as NSDecimalNumber)
            : 0
        let targetHeight = max(4, 100 * ratio)
        let isToday = Calendar.current.isDateInToday(day.date)

        return VStack(spacing: 0) {
            Spacer()
            UnevenRoundedRectangle(
                topLeadingRadius: 5,
                bottomLeadingRadius: 2,
                bottomTrailingRadius: 2,
                topTrailingRadius: 5,
                style: .continuous
            )
            .fill(
                isToday
                    ? LinearGradient(
                        colors: [theme.color.accent, theme.color.accent.opacity(0.5)],
                        startPoint: .top, endPoint: .bottom
                      )
                    : LinearGradient(
                        colors: [theme.color.surfaceSecondary, theme.color.surfaceTertiary.opacity(0.6)],
                        startPoint: .top, endPoint: .bottom
                      )
            )
            .frame(height: appeared ? targetHeight : 4)
            .animation(
                .spring(response: 0.5, dampingFraction: 0.75).delay(Double(index) * 0.05),
                value: appeared
            )
        }
        .frame(maxWidth: .infinity)
    }
}
