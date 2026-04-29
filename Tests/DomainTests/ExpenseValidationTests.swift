import Testing
import Foundation
@testable import Domain

@Suite("ExpenseValidation")
struct ExpenseValidationTests {

    private func makeExpense(amount: Decimal = 10, merchant: String = "Starbucks") -> NewExpense {
        NewExpense(amount: amount, currency: .myr, categoryID: nil, accountID: nil,
                   merchant: merchant, note: "", occurredAt: Date())
    }

    @Test("valid expense passes")
    func validExpensePasses() throws {
        #expect(throws: Never.self) {
            try ExpenseValidation.validate(makeExpense())
        }
    }

    @Test("zero amount throws invalidAmount")
    func zeroAmountThrows() {
        #expect(throws: DomainError.self) {
            try ExpenseValidation.validate(makeExpense(amount: 0))
        }
    }

    @Test("negative amount throws invalidAmount")
    func negativeAmountThrows() {
        #expect(throws: DomainError.self) {
            try ExpenseValidation.validate(makeExpense(amount: -5))
        }
    }

    @Test("blank merchant throws invalidMerchant")
    func blankMerchantThrows() {
        #expect(throws: DomainError.self) {
            try ExpenseValidation.validate(makeExpense(merchant: "   "))
        }
    }

    @Test("empty merchant throws invalidMerchant")
    func emptyMerchantThrows() {
        #expect(throws: DomainError.self) {
            try ExpenseValidation.validate(makeExpense(merchant: ""))
        }
    }
}
