import Foundation

enum ExpenseSource: String, CaseIterable, Codable {
    case notification = "Notification"
    case receipt = "Receipt Scan"
    case manual = "Manual"

    var icon: String {
        switch self {
        case .notification: "bell.fill"
        case .receipt: "doc.viewfinder"
        case .manual: "square.and.pencil"
        }
    }
}
