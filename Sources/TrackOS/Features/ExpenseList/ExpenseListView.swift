import SwiftUI
import SwiftData
import UIKit

struct ExpenseListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]

    @State private var searchText = ""
    @State private var selectedCategory: ExpenseCategory?
    @State private var showAddExpense = false

    var filteredExpenses: [Expense] {
        expenses.filter { expense in
            let matchesSearch = searchText.isEmpty
                || expense.merchant.localizedCaseInsensitiveContains(searchText)
                || (expense.notes?.localizedCaseInsensitiveContains(searchText) ?? false)
            let matchesCategory = selectedCategory == nil
                || expense.expenseCategory == selectedCategory
            return matchesSearch && matchesCategory
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category filter strip
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(title: "All", isSelected: selectedCategory == nil) {
                            selectedCategory = nil
                        }
                        ForEach(ExpenseCategory.allCases, id: \.self) { cat in
                            FilterChip(title: cat.rawValue, isSelected: selectedCategory == cat) {
                                selectedCategory = selectedCategory == cat ? nil : cat
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }

                List {
                    ForEach(filteredExpenses) { expense in
                        NavigationLink(destination: ExpenseDetailView(expense: expense)) {
                            ExpenseRowView(expense: expense)
                        }
                    }
                    .onDelete(perform: deleteExpenses)
                }
                .listStyle(.plain)
            }
            .navigationTitle("Expenses")
            .searchable(text: $searchText, prompt: "Search by merchant or notes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showAddExpense = true } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showAddExpense) {
                AddExpenseView()
            }
        }
    }

    private func deleteExpenses(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredExpenses[index])
        }
    }
}

// MARK: - Row

struct ExpenseRowView: View {
    let expense: Expense

    var body: some View {
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
                HStack(spacing: 4) {
                    Text(expense.date, format: .dateTime.month(.abbreviated).day().year())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Image(systemName: expense.expenseSource.icon)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            Text(expense.amount, format: .currency(code: expense.currency))
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Detail

struct ExpenseDetailView: View {
    let expense: Expense

    var body: some View {
        List {
            Section {
                LabeledContent("Amount") {
                    Text(expense.amount, format: .currency(code: expense.currency))
                        .fontWeight(.semibold)
                }
                LabeledContent("Merchant", value: expense.merchant)
                LabeledContent("Category", value: expense.expenseCategory.rawValue)
                LabeledContent("Date") {
                    Text(expense.date, format: .dateTime.month().day().year())
                }
                LabeledContent("Source", value: expense.expenseSource.rawValue)
            }

            if let notes = expense.notes, !notes.isEmpty {
                Section("Notes") { Text(notes) }
            }

            if let raw = expense.rawSourceText, !raw.isEmpty {
                Section("Source Text") {
                    Text(raw)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if let data = expense.receiptImageData, let image = UIImage(data: data) {
                Section("Receipt") {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .navigationTitle(expense.merchant)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.secondary.opacity(0.15))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}
