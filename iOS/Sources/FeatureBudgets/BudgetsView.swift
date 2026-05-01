import SwiftUI
import Domain
import DesignSystem

public struct BudgetsView: View {
    @Environment(\.theme) private var theme
    @Environment(\.budgetService) private var budgetService

    @State private var model: BudgetsModel?

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
            let m = BudgetsModel(budgetService: budgetService)
            model = m
            await m.load()
        }
    }

    @ViewBuilder
    private func content(_ model: BudgetsModel) -> some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: theme.space.xl) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Budgets")
                            .font(theme.font.title(28))
                            .foregroundStyle(theme.color.text)
                        if model.exceededBudgets.isEmpty {
                            Text("On track")
                                .font(theme.font.body(14))
                                .foregroundStyle(theme.color.good)
                        } else {
                            Text("\(model.exceededBudgets.count) exceeded")
                                .font(theme.font.body(14))
                                .foregroundStyle(theme.color.danger)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, theme.space.xl)
                .padding(.top, theme.space.xl)

                // Summary rings
                if !model.budgets.isEmpty {
                    summaryRings(model.budgets)
                        .padding(.horizontal, theme.space.xl)
                }

                // Budget list
                if model.isLoading {
                    ProgressView()
                        .padding(theme.space.xxxl)
                } else if model.budgets.isEmpty {
                    emptyState
                } else {
                    VStack(spacing: theme.space.sm) {
                        ForEach(model.budgets) { budget in
                            BudgetRow(budget: budget)
                        }
                    }
                    .padding(.horizontal, theme.space.xl)
                }
            }
            .padding(.bottom, 100)
        }
        .background(theme.color.bg)
        .refreshable { await model.load() }
    }

    private func summaryRings(_ budgets: [BudgetDTO]) -> some View {
        VStack(alignment: .leading, spacing: theme.space.md) {
            Text("Overview")
                .font(theme.font.label(13))
                .foregroundStyle(theme.color.textSecondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: theme.space.xl) {
                    ForEach(budgets.prefix(4)) { budget in
                        VStack(spacing: theme.space.sm) {
                            BudgetRing(budget: budget, size: 72)
                            Text(budget.categoryName)
                                .font(theme.font.body(11))
                                .foregroundStyle(theme.color.textSecondary)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
        .padding(theme.space.xl)
        .surface(theme)
    }

    private var emptyState: some View {
        VStack(spacing: theme.space.lg) {
            Image(systemName: "chart.pie")
                .font(.system(size: 48))
                .foregroundStyle(theme.color.textTertiary)
            Text("No budgets set")
                .font(theme.font.title(17))
                .foregroundStyle(theme.color.text)
            Text("Set monthly limits to track your spending")
                .font(theme.font.body(14))
                .foregroundStyle(theme.color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(theme.space.xxxl)
    }
}
