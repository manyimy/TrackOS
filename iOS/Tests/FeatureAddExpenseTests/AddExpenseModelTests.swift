import Testing
import Foundation
@testable import FeatureAddExpense
@testable import Domain

@Suite("AddExpenseModel")
@MainActor
struct AddExpenseModelTests {

    // MARK: - Helpers

    private func makeModel() -> AddExpenseModel {
        AddExpenseModel(
            expenseService: MockExpenseService(),
            categoryService: MockCategoryService(),
            classifier: KeywordCategoryClassifier()
        )
    }

    // MARK: - Validation

    @Test("isValid is false when amount is empty")
    @MainActor func invalidWhenAmountEmpty() {
        let model = makeModel()
        model.merchant = "Starbucks"
        model.amountText = ""
        #expect(!model.isValid)
    }

    @Test("isValid is false when merchant is empty")
    @MainActor func invalidWhenMerchantEmpty() {
        let model = makeModel()
        model.amountText = "10.00"
        model.merchant = ""
        #expect(!model.isValid)
    }

    @Test("isValid is true with valid amount and merchant")
    @MainActor func validWithAmountAndMerchant() {
        let model = makeModel()
        model.amountText = "12.50"
        model.merchant = "Grab"
        #expect(model.isValid)
    }

    @Test("parsedAmount parses comma decimal separator")
    @MainActor func parsesCommaDecimal() {
        let model = makeModel()
        model.amountText = "12,50"
        #expect(model.parsedAmount == Decimal(string: "12.50"))
    }

    @Test("parsedAmount is nil for non-numeric input")
    @MainActor func nilForNonNumeric() {
        let model = makeModel()
        model.amountText = "abc"
        #expect(model.parsedAmount == nil)
    }

    // MARK: - Submit

    @Test("submit sets didSave on success")
    @MainActor func submitSetsDidSave() async {
        let model = makeModel()
        model.amountText = "20.00"
        model.merchant = "IKEA"
        await model.submit()
        #expect(model.didSave)
        #expect(model.error == nil)
    }

    @Test("submit sets error on failure")
    @MainActor func submitSetsError() async {
        let model = AddExpenseModel(
            expenseService: ThrowingExpenseService(),
            categoryService: MockCategoryService(),
            classifier: KeywordCategoryClassifier()
        )
        model.amountText = "20.00"
        model.merchant = "Shop"
        await model.submit()
        #expect(!model.didSave)
        #expect(model.error != nil)
    }
}

// MARK: - Test Doubles

private struct MockExpenseService: ExpenseServiceProtocol {
    func create(_ new: NewExpense) async throws {}
    func update(id: UUID, with new: NewExpense) async throws {}
    func delete(id: UUID) async throws {}
    func fetch(in range: DateInterval) async throws -> [ExpenseDTO] { [] }
    func total(in range: DateInterval, categoryID: UUID?) async throws -> Decimal { .zero }
}

private struct ThrowingExpenseService: ExpenseServiceProtocol {
    func create(_ new: NewExpense) async throws { throw DomainError.invalidAmount }
    func update(id: UUID, with new: NewExpense) async throws {}
    func delete(id: UUID) async throws {}
    func fetch(in range: DateInterval) async throws -> [ExpenseDTO] { [] }
    func total(in range: DateInterval, categoryID: UUID?) async throws -> Decimal { .zero }
}

private struct MockCategoryService: CategoryServiceProtocol {
    func fetchAll() async throws -> [CategoryDTO] { [] }
}
