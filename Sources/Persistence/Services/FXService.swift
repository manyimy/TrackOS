import Foundation
import Domain

/// Phase 3 v1: hardcoded rates against MYR.
/// Replace `client` with a live network client in a later iteration.
public final class FXService: FXServiceProtocol {

    public enum Client {
        case hardcoded
        public static let live: Client = .hardcoded
    }

    // Rates relative to 1 MYR (approximate mid-market)
    private static let ratesFromMYR: [CurrencyCode: Decimal] = [
        .myr: 1,
        .usd: 0.213,
        .sgd: 0.288,
        .gbp: 0.168,
        .eur: 0.196,
        .jpy: 32.1,
        .idr: 3_380,
        .thb: 7.62,
        .php: 12.1,
        .vnd: 5_340,
        .hkd: 1.66,
        .cny: 1.54,
        .twd: 6.83,
        .krw: 291,
        .aud: 0.327,
    ]

    public init(client: Client = .hardcoded) {}

    public func rate(from: CurrencyCode, to: CurrencyCode, on date: Date) async throws -> Decimal {
        guard let fromRate = Self.ratesFromMYR[from], let toRate = Self.ratesFromMYR[to],
              fromRate != 0
        else { throw DomainError.fxUnavailable }
        return toRate / fromRate
    }

    public func convert(_ amount: Decimal, from: CurrencyCode, to: CurrencyCode, on date: Date) async throws -> Decimal {
        let r = try await rate(from: from, to: to, on: date)
        var result = amount * r
        var rounded = Decimal.zero
        NSDecimalRound(&rounded, &result, 2, .bankers)
        return rounded
    }
}
