import Foundation
import SwiftData

@Model
public final class Account {
    @Attribute(.unique) public var id: UUID = UUID()
    public var name: String = ""
    public var institutionName: String = ""
    public var colorHex: String = "#A1A1AA"
    public var symbolName: String = "creditcard"
    public var isDefault: Bool = false
    public var currencyRaw: String = "myr"
    public var createdAt: Date = Date()

    public var currency: CurrencyCode {
        CurrencyCode(rawValue: currencyRaw) ?? .myr
    }

    public init(
        id: UUID = UUID(),
        name: String,
        institutionName: String = "",
        colorHex: String = "#A1A1AA",
        symbolName: String = "creditcard",
        currency: CurrencyCode = .myr,
        isDefault: Bool = false
    ) {
        self.id = id
        self.name = name
        self.institutionName = institutionName
        self.colorHex = colorHex
        self.symbolName = symbolName
        self.currencyRaw = currency.rawValue
        self.isDefault = isDefault
    }
}
