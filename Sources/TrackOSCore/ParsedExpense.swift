import Foundation

struct ParsedExpense: Identifiable {
    let id: UUID = UUID()
    let amount: Double
    let currency: String
    let merchant: String
    let category: ExpenseCategory
    let date: Date
    let rawText: String
}
