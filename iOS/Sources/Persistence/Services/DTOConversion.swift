import Foundation
import Domain

extension ExpenseDTO {
    init(_ entity: Expense) {
        self.init(
            id: entity.id,
            amount: entity.amount,
            currency: entity.currency,
            amountInBaseCurrency: entity.amount, // FX applied at service layer when needed
            categoryID: entity.category?.id,
            categoryName: entity.category?.name,
            categoryColor: entity.category?.colorHex,
            categorySymbol: entity.category?.symbolName,
            merchant: entity.merchant,
            note: entity.note,
            occurredAt: entity.occurredAt
        )
    }
}
