import Foundation
import SwiftData
import Domain

@ModelActor
public actor AccountRepository {

    public func all() throws -> [Account] {
        try modelContext.fetch(FetchDescriptor<Account>(
            sortBy: [SortDescriptor(\.name)]
        ))
    }

    public func create(
        name: String,
        institutionName: String = "",
        colorHex: String = "#A1A1AA",
        symbolName: String = "creditcard",
        currency: CurrencyCode = .myr,
        isDefault: Bool = false
    ) throws {
        let account = Account(
            name: name,
            institutionName: institutionName,
            colorHex: colorHex,
            symbolName: symbolName,
            currency: currency,
            isDefault: isDefault
        )
        modelContext.insert(account)
        try modelContext.save()
    }

    public func delete(id: UUID) throws {
        let pred = #Predicate<Account> { $0.id == id }
        try modelContext.delete(model: Account.self, where: pred)
        try modelContext.save()
    }
}
