import Foundation

public enum BudgetPeriod: String, Codable, Sendable, CaseIterable {
    case daily, weekly, monthly, yearly

    public var displayName: String {
        switch self {
        case .daily:   "Daily"
        case .weekly:  "Weekly"
        case .monthly: "Monthly"
        case .yearly:  "Yearly"
        }
    }
}
