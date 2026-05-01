import SwiftUI
import Domain
import DesignSystem

public struct AddExpenseSheet: View {
    @Environment(\.theme) private var theme

    private let service: any ExpenseServiceProtocol
    private let categoryService: any CategoryServiceProtocol
    private let classifier: KeywordCategoryClassifier
    private let onDismiss: () -> Void

    @State private var model: AddExpenseModel?

    public init(
        service: any ExpenseServiceProtocol,
        categoryService: any CategoryServiceProtocol,
        classifier: KeywordCategoryClassifier,
        onDismiss: @escaping () -> Void
    ) {
        self.service = service
        self.categoryService = categoryService
        self.classifier = classifier
        self.onDismiss = onDismiss
    }

    public var body: some View {
        Group {
            if let model {
                form(model)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(theme.color.bg)
            }
        }
        .task {
            let m = AddExpenseModel(
                expenseService: service,
                categoryService: categoryService,
                classifier: classifier
            )
            model = m
            await m.loadCategories()
        }
    }

    @ViewBuilder
    private func form(_ model: AddExpenseModel) -> some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: theme.space.xl) {

                    // Amount
                    amountSection(model)

                    // Merchant
                    fieldSection(title: "Merchant") {
                        TextField("e.g. Starbucks", text: Binding(
                            get: { model.merchant },
                            set: { model.merchant = $0 }
                        ))
                        .font(theme.font.body(16))
                        .foregroundStyle(theme.color.text)
                        .padding(theme.space.md)
                        .surface(theme)
                    }

                    // Date
                    fieldSection(title: "Date") {
                        DatePicker(
                            "",
                            selection: Binding(
                                get: { model.occurredAt },
                                set: { model.occurredAt = $0 }
                            ),
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .labelsHidden()
                        .padding(theme.space.md)
                        .surface(theme)
                    }

                    // Category
                    if !model.categories.isEmpty {
                        VStack(alignment: .leading, spacing: theme.space.sm) {
                            Text("Category")
                                .font(theme.font.label(13))
                                .foregroundStyle(theme.color.textSecondary)
                                .padding(.horizontal, theme.space.xl)
                            CategoryChipRow(
                                categories: model.categories,
                                selectedID: Binding(
                                    get: { model.selectedCategoryID },
                                    set: { model.selectedCategoryID = $0 }
                                )
                            )
                        }
                    }

                    // Note
                    fieldSection(title: "Note (optional)") {
                        TextField("Add a note", text: Binding(
                            get: { model.note },
                            set: { model.note = $0 }
                        ))
                        .font(theme.font.body(16))
                        .foregroundStyle(theme.color.text)
                        .padding(theme.space.md)
                        .surface(theme)
                    }

                    // Error
                    if let error = model.error {
                        Text(error.localizedDescription)
                            .font(theme.font.body(13))
                            .foregroundStyle(.red)
                            .padding(.horizontal, theme.space.xl)
                    }
                }
                .padding(.bottom, theme.space.xxxl)
            }
            .background(theme.color.bg)
            .navigationTitle("Add Expense")
            #if os(iOS) && !targetEnvironment(macCatalyst)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onDismiss() }
                        .foregroundStyle(theme.color.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task { await saveAndDismiss(model) }
                    }
                    .font(theme.font.label(16))
                    .foregroundStyle(model.isValid ? theme.color.accent : theme.color.textTertiary)
                    .disabled(!model.isValid || model.isSubmitting)
                }
            }
            .onChange(of: model.didSave) { _, saved in
                if saved { onDismiss() }
            }
        }
    }

    private func saveAndDismiss(_ model: AddExpenseModel) async {
        await model.submit()
    }

    @ViewBuilder
    private func amountSection(_ model: AddExpenseModel) -> some View {
        VStack(alignment: .leading, spacing: theme.space.sm) {
            Text("Amount")
                .font(theme.font.label(13))
                .foregroundStyle(theme.color.textSecondary)
                .padding(.horizontal, theme.space.xl)

            HStack(spacing: theme.space.sm) {
                // Currency picker
                Menu {
                    ForEach(CurrencyCode.allCases, id: \.self) { code in
                        Button(code.rawValue) {
                            model.selectedCurrency = code
                        }
                    }
                } label: {
                    Text(model.selectedCurrency.symbol)
                        .font(theme.font.label(16))
                        .foregroundStyle(theme.color.text)
                        .frame(width: 44, height: 44)
                        .surface(theme)
                }

                TextField("0.00", text: Binding(
                    get: { model.amountText },
                    set: { model.amountText = $0 }
                ))
                #if os(iOS) && !targetEnvironment(macCatalyst)
                .keyboardType(.decimalPad)
                #endif
                .font(theme.font.display(32))
                .foregroundStyle(theme.color.text)
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, theme.space.xl)
        }
    }

    @ViewBuilder
    private func fieldSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: theme.space.sm) {
            Text(title)
                .font(theme.font.label(13))
                .foregroundStyle(theme.color.textSecondary)
                .padding(.horizontal, theme.space.xl)
            content()
                .padding(.horizontal, theme.space.xl)
        }
    }
}
