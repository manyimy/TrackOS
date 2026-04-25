import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @StateObject private var viewModel = DashboardViewModel()
    @State private var showAddExpense = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    SummaryCardView(
                        total: viewModel.monthlyTotal(expenses),
                        currency: viewModel.dominantCurrency(expenses),
                        count: viewModel.currentMonthExpenses(expenses).count
                    )

                    CategoryBreakdownView(
                        breakdown: viewModel.categoryBreakdown(expenses),
                        currency: viewModel.dominantCurrency(expenses)
                    )

                    RecentExpensesView(expenses: Array(expenses.prefix(5)))
                }
                .padding()
            }
            .navigationTitle("TrackOS")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddExpense = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showAddExpense) {
                AddExpenseView()
            }
        }
    }
}

// MARK: - Subviews

private struct SummaryCardView: View {
    let total: Double
    let currency: String
    let count: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("This Month")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(total, format: .currency(code: currency))
                .font(.system(size: 42, weight: .bold, design: .rounded))
            Text("\(count) expense\(count == 1 ? "" : "s")")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.blue.gradient.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

private struct CategoryBreakdownView: View {
    let breakdown: [(category: ExpenseCategory, total: Double)]
    let currency: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("By Category")
                .font(.headline)

            if breakdown.isEmpty {
                Text("No expenses this month")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            } else {
                ForEach(breakdown.prefix(6), id: \.category) { item in
                    HStack(spacing: 12) {
                        Image(systemName: item.category.icon)
                            .foregroundStyle(item.category.color)
                            .frame(width: 20)

                        Text(item.category.rawValue)
                            .font(.subheadline)

                        Spacer()

                        Text(item.total, format: .currency(code: currency))
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct RecentExpensesView: View {
    let expenses: [Expense]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Recent")
                .font(.headline)

            if expenses.isEmpty {
                Text("No expenses yet. Add one with + or scan a receipt.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            } else {
                ForEach(expenses) { expense in
                    HStack(spacing: 12) {
                        Image(systemName: expense.expenseCategory.icon)
                            .foregroundStyle(expense.expenseCategory.color)
                            .frame(width: 36, height: 36)
                            .background(expense.expenseCategory.color.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(expense.merchant)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .lineLimit(1)
                            Text(expense.date, format: .dateTime.month(.abbreviated).day())
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(expense.amount, format: .currency(code: expense.currency))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
