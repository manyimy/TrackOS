import Testing
import Foundation
@testable import Domain

@Suite("CurrencyCode")
struct CurrencyCodeTests {

    @Test("format rounds to 2 decimal places")
    func formatDecimalPlaces() {
        let result = CurrencyCode.usd.format(Decimal(string: "42.5")!)
        #expect(result.contains("42.50"))
    }

    @Test("format uses correct symbol for MYR")
    func formatMYR() {
        let result = CurrencyCode.myr.format(10)
        #expect(result.contains("RM"))
    }

    @Test("format uses correct symbol for SGD")
    func formatSGD() {
        let result = CurrencyCode.sgd.format(10)
        #expect(result.contains("S$"))
    }

    @Test("format uses correct symbol for EUR")
    func formatEUR() {
        let result = CurrencyCode.eur.format(10)
        #expect(result.contains("€"))
    }

    @Test("format zero amount")
    func formatZero() {
        let result = CurrencyCode.usd.format(0)
        #expect(result.contains("0.00"))
    }
}
