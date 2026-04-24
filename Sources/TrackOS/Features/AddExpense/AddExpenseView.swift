import SwiftUI
import SwiftData

struct AddExpenseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var amount: Double = 0
    @State private var currency: String = "USD"
    @State private var merchant: String = ""
    @State private var category: ExpenseCategory = .other
    @State private var date: Date = Date()
    @State private var notes: String = ""

    private let currencies = ["USD", "EUR", "GBP", "CAD", "AUD", "JPY", "CHF", "INR"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Amount") {
                    HStack {
                        Picker("Currency", selection: $currency) {
                            ForEach(currencies, id: \.self) { Text($0) }
                        }
                        .labelsHidden()
                        .fixedSize()

                        TextField("0.00", value: $amount, format: .number)
                            .keyboardType(.decimalPad)
                            .font(.title2)
                            .fontWeight(.medium)
                    }
                }

                Section("Details") {
                    TextField("Merchant name", text: $merchant)

                    Picker("Category", selection: $category) {
                        ForEach(ExpenseCategory.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                        }
                    }

                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                Section("Notes") {
                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(merchant.trimmingCharacters(in: .whitespaces).isEmpty || amount <= 0)
                }
            }
        }
    }

    private func save() {
        let expense = Expense(
            amount: amount,
            currency: currency,
            merchant: merchant.trimmingCharacters(in: .whitespaces),
            category: category,
            date: date,
            notes: notes.isEmpty ? nil : notes,
            source: .manual
        )
        modelContext.insert(expense)
        dismiss()
    }
}
