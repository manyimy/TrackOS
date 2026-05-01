import Foundation
import Observation
import Domain

@Observable
@MainActor
public final class AddExpenseModel {

    // MARK: - Form State
    public var amountText: String = ""
    public var merchant: String = ""
    public var note: String = ""
    public var occurredAt: Date = Date()
    public var selectedCategoryID: UUID?
    public var selectedCurrency: CurrencyCode = .myr
    public var categories: [CategoryDTO] = []

    // MARK: - Status
    public var isSubmitting = false
    public var error: UserFacingError?
    public var didSave = false

    // MARK: - Derived
    public var parsedAmount: Decimal? {
        Decimal(string: amountText.replacingOccurrences(of: ",", with: "."))
    }

    public var isValid: Bool {
        parsedAmount != nil && parsedAmount! > 0 && !merchant.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Dependencies
    private let expenseService: any ExpenseServiceProtocol
    private let categoryService: any CategoryServiceProtocol
    private let classifier: KeywordCategoryClassifier

    public init(
        expenseService: any ExpenseServiceProtocol,
        categoryService: any CategoryServiceProtocol,
        classifier: KeywordCategoryClassifier
    ) {
        self.expenseService = expenseService
        self.categoryService = categoryService
        self.classifier = classifier
    }

    // MARK: - Intents
    public func loadCategories() async {
        do {
            categories = try await categoryService.fetchAll()
        } catch {
            self.error = UserFacingError(from: error)
        }
    }

    public func submit() async {
        guard let amount = parsedAmount, isValid else { return }
        isSubmitting = true
        error = nil
        defer { isSubmitting = false }

        let trimmedMerchant = merchant.trimmingCharacters(in: .whitespaces)
        let resolvedCategoryID = selectedCategoryID
            ?? classifier.predict(merchant: trimmedMerchant, note: note)

        let request = NewExpense(
            amount: amount,
            currency: selectedCurrency,
            categoryID: resolvedCategoryID,
            accountID: nil,
            merchant: trimmedMerchant,
            note: note.trimmingCharacters(in: .whitespaces),
            occurredAt: occurredAt
        )

        do {
            try await expenseService.create(request)
            didSave = true
        } catch {
            self.error = UserFacingError(from: error)
        }
    }
}
