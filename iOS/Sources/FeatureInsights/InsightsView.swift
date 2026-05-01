import SwiftUI
import Domain
import DesignSystem

public struct InsightsView: View {
    @Environment(\.theme) private var theme
    @Environment(\.insightEngine) private var insightEngine

    @State private var model: InsightsModel?

    public init() {}

    public var body: some View {
        Group {
            if let model {
                content(model)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(theme.color.bg)
            }
        }
        .task {
            let m = InsightsModel(insightEngine: insightEngine)
            model = m
            await m.load()
        }
    }

    @ViewBuilder
    private func content(_ model: InsightsModel) -> some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: theme.space.xl) {
                // Header
                HStack {
                    Text("Insights")
                        .font(theme.font.title(28))
                        .foregroundStyle(theme.color.text)
                    Spacer()
                }
                .padding(.horizontal, theme.space.xl)
                .padding(.top, theme.space.xl)

                // Period picker
                periodPicker(model)
                    .padding(.horizontal, theme.space.xl)

                if model.isLoading {
                    ProgressView()
                        .padding(theme.space.xxxl)
                } else {
                    // Trend chart
                    SpendingChart(data: model.dailySpend)
                        .padding(.horizontal, theme.space.xl)

                    // Category breakdown
                    if !model.categoryBreakdown.isEmpty {
                        CategoryBreakdown(
                            items: model.categoryBreakdown,
                            currency: .myr
                        )
                        .padding(.horizontal, theme.space.xl)
                    }

                    // Smart tips
                    if !model.smartTips.isEmpty {
                        tipsSection(model.smartTips)
                    }
                }
            }
            .padding(.bottom, 100)
        }
        .background(theme.color.bg)
        .refreshable { await model.load() }
        .task(id: model.selectedPeriod) { await model.load() }
    }

    private func periodPicker(_ model: InsightsModel) -> some View {
        HStack(spacing: 0) {
            ForEach(InsightsModel.Period.allCases, id: \.self) { period in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        model.selectedPeriod = period
                    }
                } label: {
                    Text(period.rawValue)
                        .font(theme.font.label(14))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .foregroundStyle(model.selectedPeriod == period
                                         ? theme.color.text : theme.color.textSecondary)
                        .background {
                            if model.selectedPeriod == period {
                                RoundedRectangle(cornerRadius: theme.radius.sm, style: .continuous)
                                    .fill(theme.color.surfaceSecondary)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(theme.color.surfaceTertiary)
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous))
    }

    @ViewBuilder
    private func tipsSection(_ tips: [SmartTip]) -> some View {
        VStack(alignment: .leading, spacing: theme.space.md) {
            Text("Smart Tips")
                .font(theme.font.title(17))
                .foregroundStyle(theme.color.text)
                .padding(.horizontal, theme.space.xl)

            VStack(spacing: theme.space.sm) {
                ForEach(tips) { tip in
                    tipCard(tip)
                }
            }
            .padding(.horizontal, theme.space.xl)
        }
    }

    private func tipCard(_ tip: SmartTip) -> some View {
        HStack(spacing: theme.space.md) {
            Image(systemName: tip.icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(theme.color.accent)
                .frame(width: 36, height: 36)
                .background(theme.color.accent.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(tip.title)
                    .font(theme.font.label(14))
                    .foregroundStyle(theme.color.text)
                Text(tip.body)
                    .font(theme.font.body(13))
                    .foregroundStyle(theme.color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(theme.space.lg)
        .surface(theme)
    }
}
