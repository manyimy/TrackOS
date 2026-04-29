import Foundation

public enum CurrencyCode: String, Codable, Sendable, CaseIterable {
    case myr, sgd, usd, gbp, eur, jpy, idr, thb, php, vnd, hkd, cny, twd, krw, aud

    public var symbol: String {
        switch self {
        case .myr: "RM"
        case .sgd: "S$"
        case .usd: "$"
        case .gbp: "£"
        case .eur: "€"
        case .jpy: "¥"
        case .idr: "Rp"
        case .thb: "฿"
        case .php: "₱"
        case .vnd: "₫"
        case .hkd: "HK$"
        case .cny: "¥"
        case .twd: "NT$"
        case .krw: "₩"
        case .aud: "A$"
        }
    }

    public var displayName: String { rawValue.uppercased() }

    public func format(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = rawValue.uppercased()
        formatter.roundingMode = .bankers
        return formatter.string(from: amount as NSDecimalNumber) ?? "\(symbol)\(amount)"
    }
}
