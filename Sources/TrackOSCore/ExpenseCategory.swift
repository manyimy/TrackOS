import Foundation

enum ExpenseCategory: String, CaseIterable, Codable {
    case food = "Food & Dining"
    case groceries = "Groceries"
    case transport = "Transportation"
    case travel = "Travel"
    case shopping = "Shopping"
    case entertainment = "Entertainment"
    case health = "Health & Medical"
    case utilities = "Utilities"
    case housing = "Housing"
    case subscriptions = "Subscriptions"
    case other = "Other"

    var icon: String {
        switch self {
        case .food: "fork.knife"
        case .groceries: "cart.fill"
        case .transport: "car.fill"
        case .travel: "airplane"
        case .shopping: "bag.fill"
        case .entertainment: "tv.fill"
        case .health: "cross.fill"
        case .utilities: "bolt.fill"
        case .housing: "house.fill"
        case .subscriptions: "repeat.circle.fill"
        case .other: "ellipsis.circle.fill"
        }
    }
}
