import SwiftUI
import SwiftData

struct AddExpenseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var amountText: String = ""
    @State private var currency: String = "MYR"
    @State private var merchant: String = ""
    @State private var category: ExpenseCategory = .other
    @State private var date: Date = Date()
    @State private var notes: String = ""
    @State private var showDetails = false

    private var amount: Double { Double(amountText) ?? 0 }
    private var canSave: Bool { !merchant.trimmingCharacters(in: .whitespaces).isEmpty && amount > 0 }

    private let currencies = ["MYR", "USD", "CNY", "JPY", "GBP", "EUR", "SGD", "HKD", "AUD", "CAD", "THB", "IDR", "INR", "KRW", "CHF", "TWD"]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    amountSection
                    merchantSection
                    categorySection
                    detailsSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("New Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .fontWeight(.semibold)
                        .disabled(!canSave)
                }
            }
        }
    }

    // MARK: - Amount

    private var amountSection: some View {
        VStack(spacing: 12) {
            // Currency row
            HStack {
                Spacer()
                Menu {
                    ForEach(currencies, id: \.self) { code in
                        Button(code) { currency = code }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(currency)
                            .font(.headline)
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption)
                    }
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(.blue.opacity(0.1))
                    .clipShape(Capsule())
                }
                Spacer()
            }

            // Big amount display
            ZStack(alignment: .center) {
                Text(amountText.isEmpty ? "0.00" : amountText)
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(amountText.isEmpty ? Color(.tertiaryLabel) : .primary)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 72)

            // Hidden text field driving the keyboard
            TextField("", text: $amountText)
                .keyboardType(.decimalPad)
                .focused($amountFocused)
                .opacity(0)
                .frame(height: 0)
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .onTapGesture { amountFocused = true }
    }

    @FocusState private var amountFocused: Bool

    // MARK: - Merchant

    private var merchantSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Where did you spend?")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            TextField("Merchant name", text: $merchant)
                .font(.body)
                .padding(14)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .onChange(of: merchant) { _, newValue in
                    autoDetectCategory(from: newValue)
                }
        }
    }

    // MARK: - Category

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(ExpenseCategory.allCases, id: \.self) { cat in
                    CategoryGridCell(
                        category: cat,
                        isSelected: category == cat
                    ) {
                        withAnimation(.spring(response: 0.25)) {
                            category = cat
                        }
                    }
                }
            }
        }
    }

    // MARK: - Details (collapsible)

    private var detailsSection: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.3)) { showDetails.toggle() }
            } label: {
                HStack {
                    Text("More details")
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Image(systemName: showDetails ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(16)
            }
            .buttonStyle(.plain)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: showDetails ? 0 : 16, style: .continuous))
            .clipShape(UnevenRoundedRectangle(topLeadingRadius: 16, topTrailingRadius: 16))

            if showDetails {
                VStack(spacing: 1) {
                    Divider().padding(.horizontal, 16)

                    HStack {
                        Text("Date")
                            .foregroundStyle(.secondary)
                        Spacer()
                        DatePicker("", selection: $date, displayedComponents: .date)
                            .labelsHidden()
                    }
                    .padding(16)
                    .background(Color(.secondarySystemGroupedBackground))

                    Divider().padding(.horizontal, 16)

                    TextField("Add a note…", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                        .padding(16)
                        .background(Color(.secondarySystemGroupedBackground))
                }
                .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 16, bottomTrailingRadius: 16))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }

    // MARK: - Helpers

    private func autoDetectCategory(from text: String) {
        guard category == .other || category == autoCategory else { return }
        autoCategory = NotificationParserService().inferCategoryPublic(from: text.lowercased())
        category = autoCategory
    }

    @State private var autoCategory: ExpenseCategory = .other

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

// MARK: - Category Grid Cell

private struct CategoryGridCell: View {
    let category: ExpenseCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? category.color : category.color.opacity(0.12))
                        .frame(width: 48, height: 48)
                    Image(systemName: category.icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(isSelected ? .white : category.color)
                }
                Text(category.rawValue
                    .components(separatedBy: " ").first ?? category.rawValue)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(isSelected ? category.color : .secondary)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }
}
