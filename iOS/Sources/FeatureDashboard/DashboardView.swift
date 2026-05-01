import SwiftUI
import Domain
import DesignSystem

public struct DashboardView: View {
    @Environment(\.theme) private var theme
    @Environment(\.expenseService) private var expenseService
    @Environment(\.budgetService) private var budgetService
    @Environment(\.addExpensePresenter) private var addExpensePresenter

    @State private var model: DashboardModel?
    @State private var showAddExpense = false

    public init() {}

    public var body: some View {
        NavigationStack {
            Group {
                if let model {
                    content(model)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(theme.color.bg)
                }
            }
            #if os(iOS) && !targetEnvironment(macCatalyst)
            .toolbar(.hidden, for: .navigationBar)
            #endif
        }
        .task {
            let m = DashboardModel(expenseService: expenseService, budgetService: budgetService)
            model = m
            await m.load()
        }
    }

    @ViewBuilder
    private func content(_ model: DashboardModel) -> some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: theme.space.xl) {
                    // Greeting
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(model.greeting)
                                .font(theme.font.body(14))
                                .foregroundStyle(theme.color.textSecondary)
                            Text("TrackOS")
                                .font(theme.font.title(28))
                                .foregroundStyle(theme.color.text)
                        }
                        Spacer()
                        Circle()
                            .fill(theme.color.accent.opacity(0.2))
                            .frame(width: 42, height: 42)
                            .overlay(
                                Text("T")
                                    .font(theme.font.label(16))
                                    .foregroundStyle(theme.color.accent)
                            )
                    }
                    .padding(.horizontal, theme.space.xl)
                    .padding(.top, theme.space.xl)

                    // Balance card
                    BalanceCard(
                        total: model.totalSpent,
                        currency: model.currency,
                        period: model.selectedPeriod,
                        expenseCount: model.expenses.count
                    )
                    .padding(.horizontal, theme.space.xl)

                    // Period picker
                    periodPicker(model)
                        .padding(.horizontal, theme.space.xl)

                    // Quick actions
                    QuickActionsRow(
                        onAddExpense: { showAddExpense = true },
                        onScanReceipt: {}
                    )
                    .padding(.horizontal, theme.space.xl)

                    // Recent
                    if !model.expenses.isEmpty {
                        VStack(alignment: .leading, spacing: theme.space.md) {
                            Text("Recent")
                                .font(theme.font.title(17))
                                .foregroundStyle(theme.color.text)
                                .padding(.horizontal, theme.space.xl)
                            RecentActivityList(expenses: model.expenses)
                                .padding(.horizontal, theme.space.xl)
                        }
                    } else if !model.isLoading {
                        emptyState
                    }
                }
                .padding(.bottom, 100)
            }
            .background(theme.color.bg)
            .refreshable { await model.load() }

            // FAB
            Button { showAddExpense = true } label: {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(theme.color.accentInk)
                    .frame(width: 58, height: 58)
                    .background(theme.color.accent)
                    .clipShape(Circle())
                    .shadow(color: theme.color.accent.opacity(0.4), radius: 16, y: 6)
            }
            .padding(.trailing, theme.space.xl)
            .padding(.bottom, 96)
        }
        .sheet(isPresented: $showAddExpense) {
            addExpensePresenter({
                showAddExpense = false
                Task { await model.load() }
            })
        }
        .task(id: model.selectedPeriod) { await model.load() }
    }

    private func periodPicker(_ model: DashboardModel) -> some View {
        HStack(spacing: 0) {
            ForEach(DashboardModel.Period.allCases, id: \.self) { period in
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

    private var emptyState: some View {
        VStack(spacing: theme.space.lg) {
            Image(systemName: "tray.fill")
                .font(.system(size: 48))
                .foregroundStyle(theme.color.textTertiary)
            Text("No expenses yet")
                .font(theme.font.title(17))
                .foregroundStyle(theme.color.text)
            Text("Tap + to add your first expense")
                .font(theme.font.body(14))
                .foregroundStyle(theme.color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(theme.space.xxxl)
    }
}
