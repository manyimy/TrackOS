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

                    // Amount — hero section
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
                            sectionLabel("Category")
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
                            .foregroundStyle(theme.color.danger)
                            .padding(.horizontal, theme.space.xl)
                    }

                    // Save button — bottom of form
                    saveButton(model)
                        .padding(.horizontal, theme.space.xl)
                        .padding(.top, theme.space.sm)
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
                        .font(theme.font.body(16))
                        .foregroundStyle(theme.color.textSecondary)
                }
            }
            .onChange(of: model.didSave) { _, saved in
                if saved { onDismiss() }
            }
        }
    }

    @ViewBuilder
    private func amountSection(_ model: AddExpenseModel) -> some View {
        VStack(spacing: theme.space.lg) {
            // Currency + amount on one prominent line
            HStack(alignment: .firstTextBaseline, spacing: theme.space.sm) {
                Menu {
                    ForEach(CurrencyCode.allCases, id: \.self) { code in
                        Button("\(code.symbol)  \(code.rawValue.uppercased())") {
                            model.selectedCurrency = code
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(model.selectedCurrency.symbol)
                            .font(theme.font.title(28))
                            .foregroundStyle(
                                model.amountText.isEmpty
                                    ? theme.color.textTertiary : theme.color.textSecondary
                            )
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(theme.color.textTertiary)
                    }
                }

                TextField("0.00", text: Binding(
                    get: { model.amountText },
                    set: { model.amountText = $0 }
                ))
                #if os(iOS) && !targetEnvironment(macCatalyst)
                .keyboardType(.decimalPad)
                #endif
                .font(theme.font.display(48))
                .foregroundStyle(model.amountText.isEmpty ? theme.color.textTertiary : theme.color.text)
                .minimumScaleFactor(0.5)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, theme.space.xl)
            .padding(.vertical, theme.space.lg)
            .background(theme.color.surface)
            .clipShape(RoundedRectangle(cornerRadius: theme.radius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: theme.radius.card, style: .continuous)
                    .strokeBorder(
                        model.amountText.isEmpty
                            ? theme.color.border
                            : theme.color.accent.opacity(0.5),
                        lineWidth: 1
                    )
            )
            .padding(.horizontal, theme.space.xl)
            .padding(.top, theme.space.md)
        }
    }

    @ViewBuilder
    private func saveButton(_ model: AddExpenseModel) -> some View {
        Button {
            Task { await model.submit() }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                    .fill(
                        model.isValid
                            ? LinearGradient(
                                colors: [Color(hex: "#CAFF58"), Color(hex: "#94D40E")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                              )
                            : LinearGradient(
                                colors: [theme.color.surfaceSecondary, theme.color.surfaceSecondary],
                                startPoint: .top,
                                endPoint: .bottom
                              )
                    )
                    .frame(height: 52)

                if model.isSubmitting {
                    ProgressView()
                        .tint(theme.color.accentInk)
                } else {
                    Text("Save Expense")
                        .font(theme.font.label(17))
                        .foregroundStyle(model.isValid ? theme.color.accentInk : theme.color.textTertiary)
                }
            }
        }
        .disabled(!model.isValid || model.isSubmitting)
        .animation(.easeInOut(duration: 0.2), value: model.isValid)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(theme.font.label(13))
            .foregroundStyle(theme.color.textSecondary)
            .padding(.horizontal, theme.space.xl)
    }

    @ViewBuilder
    private func fieldSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: theme.space.sm) {
            sectionLabel(title)
            content()
                .padding(.horizontal, theme.space.xl)
        }
    }
}
