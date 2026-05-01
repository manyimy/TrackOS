import Foundation

public enum ExpenseValidation {
    public static func validate(_ new: NewExpense) throws {
        guard new.amount > 0 else { throw DomainError.invalidAmount }
        guard !new.merchant.trimmingCharacters(in: .whitespaces).isEmpty
        else { throw DomainError.invalidMerchant }
    }
}
