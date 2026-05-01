import Foundation

public protocol FXServiceProtocol: Sendable {
    func rate(from: CurrencyCode, to: CurrencyCode, on date: Date) async throws -> Decimal
    func convert(_ amount: Decimal, from: CurrencyCode, to: CurrencyCode, on date: Date) async throws -> Decimal
}
