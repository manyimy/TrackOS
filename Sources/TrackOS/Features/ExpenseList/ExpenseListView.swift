import SwiftUI
import SwiftData
import UIKit

struct ExpenseListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @StateObject private var viewModel = DashboardViewModel()

    @State private var searchText = ""
    @State private var selectedCategory: ExpenseCategory?
    @State private var showAddExpense = false

    private var filtered: [Expense] {
        expenses.filter { expense in
            let matchesSearch = searchText.isEmpty
                || expense.merchant.localizedCaseInsensitiveContains(searchText)
                || (expense.notes?.localizedCaseInsensitiveContains(searchText) ?? false)
            let matchesCategory = selectedCategory == nil
                || expense.expenseCategory == selectedCategory
            return matchesSearch && matchesCategory
        }
    }

    private var grouped: [(label: String, expenses: [Expense])] {
        viewModel.groupedByDate(filtered)
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Group {
                    if expenses.isEmpty {
                        emptyState
                    } else {
                        listContent
                    }
                }
                .background(Color(.systemGroupedBackground))

                fab
            }
            .navigationTitle("Expenses")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search by merchant or notes")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { EditButton() }
            }
            .sheet(isPresented: $showAddExpense) { AddExpenseView() }
        }
    }

    // MARK: - List

    private var listContent: some View {
        List {
            // Category filter chips
            Section {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        CategoryChip(label: "All", icon: "square.grid.2x2", isSelected: selectedCategory == nil) {
                            withAnimation { selectedCategory = nil }
                        }
                        ForEach(ExpenseCategory.allCases, id: \.self) { cat in
                            CategoryChip(label: cat.rawValue, icon: cat.icon, color: cat.color, isSelected: selectedCategory == cat) {
                                withAnimation { selectedCategory = selectedCategory == cat ? nil : cat }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                .listRowSeparator(.hidden)
            }

            // Date-grouped rows
            ForEach(grouped, id: \.label) { group in
                Section {
                    ForEach(group.expenses) { expense in
                        NavigationLink(destination: ExpenseDetailView(expense: expense)) {
                            ModernExpenseRow(expense: expense)
                                .padding(.vertical, 4)
                        }
                        .listRowBackground(Color(.secondarySystemGroupedBackground))
                    }
                    .onDelete { offsets in deleteExpenses(offsets, in: group.expenses) }
                } header: {
                    Text(group.label)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .textCase(nil)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "tray.fill")
                .font(.system(size: 52))
                .foregroundStyle(.blue.opacity(0.25))
            VStack(spacing: 6) {
                Text("No Expenses Yet")
                    .font(.title3.bold())
                Text("Tap + to add one manually, scan a receipt,\nor paste a notification.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            Button { showAddExpense = true } label: {
                Label("Add Expense", systemImage: "plus")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            .padding(.top, 4)
            Spacer()
        }
        .padding()
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
        .padding(.bottom, 24)
    }

    private func deleteExpenses(_ offsets: IndexSet, in group: [Expense]) {
        for index in offsets { modelContext.delete(group[index]) }
    }
}

// MARK: - Modern Expense Row (shared)

struct ModernExpenseRow: View {
    let expense: Expense

    var body: some View {
        HStack(spacing: 12) {
            // Category icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(expense.expenseCategory.color.opacity(0.14))
                    .frame(width: 44, height: 44)
                Image(systemName: expense.expenseCategory.icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(expense.expenseCategory.color)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(expense.merchant)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                HStack(spacing: 4) {
                    Text(expense.date, format: .dateTime.month(.abbreviated).day())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("·")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Image(systemName: expense.expenseSource.icon)
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            Text(expense.amount, format: .currency(code: expense.currency))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
        }
    }
}

// MARK: - Detail View

struct ExpenseDetailView: View {
    let expense: Expense

    var body: some View {
        List {
            Section {
                DetailRow(label: "Amount") {
                    Text(expense.amount, format: .currency(code: expense.currency))
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                }
                DetailRow(label: "Merchant") { Text(expense.merchant) }
                DetailRow(label: "Category") {
                    Label(expense.expenseCategory.rawValue, systemImage: expense.expenseCategory.icon)
                        .foregroundStyle(expense.expenseCategory.color)
                }
                DetailRow(label: "Date") {
                    Text(expense.date, format: .dateTime.month(.wide).day().year())
                }
                DetailRow(label: "Source") {
                    Label(expense.expenseSource.rawValue, systemImage: expense.expenseSource.icon)
                        .foregroundStyle(.secondary)
                }
            }

            if let notes = expense.notes, !notes.isEmpty {
                Section("Notes") { Text(notes).foregroundStyle(.secondary) }
            }

            if let raw = expense.rawSourceText, !raw.isEmpty {
                Section("Source Text") {
                    Text(raw).font(.caption).foregroundStyle(.secondary)
                }
            }

            if let data = expense.receiptImageData, let image = UIImage(data: data) {
                Section("Receipt") {
                    Image(uiImage: image)
                        .resizable().scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(expense.merchant)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct DetailRow<Content: View>: View {
    let label: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        HStack {
            Text(label).foregroundStyle(.secondary)
            Spacer()
            content()
        }
    }
}

// MARK: - Category Chip

struct CategoryChip: View {
    let label: String
    let icon: String
    var color: Color = .blue
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .medium))
                Text(label)
                    .font(.caption.weight(isSelected ? .semibold : .regular))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(isSelected ? color : Color(.systemFill))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
