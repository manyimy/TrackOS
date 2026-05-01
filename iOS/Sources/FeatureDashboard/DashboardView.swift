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
                    header(model)
                        .padding(.horizontal, theme.space.xl)
                        .padding(.top, theme.space.xl)

                    BalanceCard(
                        total: model.totalSpent,
                        currency: model.currency,
                        period: model.selectedPeriod,
                        expenseCount: model.expenses.count
                    )
                    .padding(.horizontal, theme.space.xl)

                    periodPicker(model)
                        .padding(.horizontal, theme.space.xl)

                    QuickActionsRow(
                        onAddExpense: { showAddExpense = true },
                        onScanReceipt: {}
                    )
                    .padding(.horizontal, theme.space.xl)

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
                .padding(.bottom, 110)
            }
            .background(theme.color.bg)
            .refreshable { await model.load() }

            fab
                .padding(.trailing, theme.space.xl)
                .padding(.bottom, 100)
        }
        .sheet(isPresented: $showAddExpense) {
            addExpensePresenter({
                showAddExpense = false
                Task { await model.load() }
            })
        }
        .task(id: model.selectedPeriod) { await model.load() }
    }

    private var fab: some View {
        Button { showAddExpense = true } label: {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#CAFF58"), Color(hex: "#94D40E")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .shadow(color: theme.color.accent.opacity(0.45), radius: 20, y: 8)
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.color.accentInk)
            }
        }
        .buttonStyle(.plain)
    }

    private func header(_ model: DashboardModel) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(model.greeting)
                    .font(theme.font.body(13))
                    .foregroundStyle(theme.color.textSecondary)
                Text("TrackOS")
                    .font(theme.font.title(26))
                    .foregroundStyle(theme.color.text)
            }
            Spacer()
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [theme.color.accent.opacity(0.3), theme.color.accent.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 42, height: 42)
                Text("T")
                    .font(theme.font.label(16))
                    .foregroundStyle(theme.color.accent)
            }
            .overlay(Circle().strokeBorder(theme.color.accent.opacity(0.25), lineWidth: 1))
        }
    }

    private func periodPicker(_ model: DashboardModel) -> some View {
        HStack(spacing: 0) {
            ForEach(DashboardModel.Period.allCases, id: \.self) { period in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        model.selectedPeriod = period
                    }
                } label: {
                    Text(period.rawValue)
                        .font(theme.font.label(13))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .foregroundStyle(
                            model.selectedPeriod == period
                                ? theme.color.text : theme.color.textTertiary
                        )
                        .background {
                            if model.selectedPeriod == period {
                                RoundedRectangle(cornerRadius: theme.radius.sm + 2, style: .continuous)
                                    .fill(theme.color.surfaceSecondary)
                                    .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
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
            ZStack {
                Circle()
                    .fill(theme.color.surfaceSecondary)
                    .frame(width: 80, height: 80)
                Image(systemName: "tray")
                    .font(.system(size: 32, weight: .light))
                    .foregroundStyle(theme.color.textTertiary)
            }
            VStack(spacing: theme.space.sm) {
                Text("No expenses yet")
                    .font(theme.font.title(17))
                    .foregroundStyle(theme.color.text)
                Text("Tap + to log your first expense")
                    .font(theme.font.body(14))
                    .foregroundStyle(theme.color.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(theme.space.xxxl)
    }
}
