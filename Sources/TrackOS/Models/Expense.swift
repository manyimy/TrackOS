import Foundation
import SwiftData

@Model
final class Expense {
    var id: UUID
    var amount: Double
    var currency: String
    var merchant: String
    var category: String
    var date: Date
    var notes: String?
    var sourceType: String
    @Attribute(.externalStorage) var receiptImageData: Data?
    var rawSourceText: String?

    init(
        amount: Double,
        currency: String = "USD",
        merchant: String,
        category: ExpenseCategory = .other,
        date: Date = Date(),
        notes: String? = nil,
        source: ExpenseSource = .manual,
        rawSourceText: String? = nil,
        receiptImageData: Data? = nil
    ) {
        self.id = UUID()
        self.amount = amount
        self.currency = currency
        self.merchant = merchant
        self.category = category.rawValue
        self.date = date
        self.notes = notes
        self.sourceType = source.rawValue
        self.rawSourceText = rawSourceText
        self.receiptImageData = receiptImageData
    }

    var expenseCategory: ExpenseCategory {
        ExpenseCategory(rawValue: category) ?? .other
    }

    var expenseSource: ExpenseSource {
        ExpenseSource(rawValue: sourceType) ?? .manual
    }

    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: NSNumber(value: amount)) ?? "\(currency) \(amount)"
    }
}
