import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @StateObject private var viewModel = DashboardViewModel()
    @State private var selectedPeriod: TimePeriod = .month
    @State private var showAddExpense = false

    private var currency: String { viewModel.dominantCurrency(expenses) }
    private var periodExpenses: [Expense] { viewModel.filteredExpenses(expenses, for: selectedPeriod) }
    private var breakdown: [(category: ExpenseCategory, total: Double)] {
        viewModel.categoryBreakdown(expenses, period: selectedPeriod)
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        greetingHeader
                        summaryCard
                        periodPicker
                        if !breakdown.isEmpty { spendingChart }
                        recentSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 104)
                }
                .background(Color(.systemGroupedBackground))

                fab
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showAddExpense) { AddExpenseView() }
        }
    }

    // MARK: - Greeting Header

    private var greetingHeader: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.greeting)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("TrackOS")
                    .font(.title.bold())
            }
            Spacer()
            Circle()
                .fill(.blue.gradient)
                .frame(width: 42, height: 42)
                .overlay {
                    Text("T").font(.headline.bold()).foregroundStyle(.white)
                }
        }
    }

    // MARK: - Summary Card

    private var summaryCard: some View {
        ZStack(alignment: .topLeading) {
            // Background
            RoundedRectangle(cornerRadius: 24)
                .fill(.blue.gradient)

            // Decorative blobs
            Circle()
                .fill(.white.opacity(0.07))
                .frame(width: 220)
                .offset(x: 120, y: -70)
            Circle()
                .fill(.white.opacity(0.05))
                .frame(width: 160)
                .offset(x: -40, y: 80)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Total Spent")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                    Spacer()
                    Label("\(periodExpenses.count)", systemImage: "creditcard.fill")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.85))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.white.opacity(0.18))
                        .clipShape(Capsule())
                }

                Text(viewModel.total(expenses, period: selectedPeriod),
                     format: .currency(code: currency))
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                if let top = breakdown.first {
                    HStack(spacing: 5) {
                        Image(systemName: top.category.icon)
                        Text("Most on \(top.category.rawValue)")
                    }
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.72))
                }
            }
            .padding(24)
        }
        .frame(height: 162)
        .shadow(color: .blue.opacity(0.28), radius: 20, y: 8)
    }

    // MARK: - Period Picker

    private var periodPicker: some View {
        HStack(spacing: 0) {
            ForEach(TimePeriod.allCases, id: \.self) { period in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedPeriod = period
                    }
                } label: {
                    Text(period.rawValue)
                        .font(.subheadline)
                        .fontWeight(selectedPeriod == period ? .semibold : .regular)
                        .foregroundStyle(selectedPeriod == period ? .primary : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background {
                            if selectedPeriod == period {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color(.systemFill))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Spending Chart

    private var spendingChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("By Category")
                .font(.headline)

            HStack(alignment: .center, spacing: 16) {
                // Donut
                ZStack {
                    Chart(breakdown.prefix(6), id: \.category) { item in
                        SectorMark(
                            angle: .value("Amount", item.total),
                            innerRadius: .ratio(0.62),
                            angularInset: 2.5
                        )
                        .cornerRadius(5)
                        .foregroundStyle(item.category.color)
                    }

                    // Centre label
                    VStack(spacing: 1) {
                        Text(breakdown.count.description)
                            .font(.title3.bold())
                        Text("categories")
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 120, height: 120)

                // Legend
                VStack(alignment: .leading, spacing: 9) {
                    ForEach(breakdown.prefix(5), id: \.category) { item in
                        HStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(item.category.color)
                                .frame(width: 10, height: 10)
                            Text(item.category.rawValue)
                                .font(.caption)
                                .lineLimit(1)
                            Spacer(minLength: 4)
                            Text(item.total, format: .currency(code: currency))
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.04), radius: 12, y: 4)
    }

    // MARK: - Recent Transactions

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Recent")
                    .font(.headline)
                Spacer()
                NavigationLink("See all") { ExpenseListView() }
                    .font(.subheadline)
            }

            if expenses.isEmpty {
                emptyState
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(expenses.prefix(5).enumerated()), id: \.element.id) { idx, expense in
                        ModernExpenseRow(expense: expense)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                        if idx < min(4, expenses.count - 1) {
                            Divider().padding(.leading, 64)
                        }
                    }
                }
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: .black.opacity(0.04), radius: 12, y: 4)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.pie.fill")
                .font(.system(size: 40))
                .foregroundStyle(.blue.opacity(0.3))
            Text("No expenses yet")
                .font(.subheadline.weight(.medium))
            Text("Tap + to add your first one")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - FAB

    private var fab: some View {
        Button { showAddExpense = true } label: {
            Image(systemName: "plus")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 58, height: 58)
                .background(.blue)
                .clipShape(Circle())
                .shadow(color: .blue.opacity(0.38), radius: 16, y: 8)
        }
        .padding(.trailing, 24)
        .padding(.bottom, 96)
    }
}
