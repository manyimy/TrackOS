#if os(iOS)
import SwiftUI
import TrackOSCore

extension ExpenseCategory {
    var color: Color {
        switch self {
        case .food: .orange
        case .groceries: .mint
        case .transport: .blue
        case .travel: .cyan
        case .shopping: .purple
        case .entertainment: .red
        case .health: .green
        case .utilities: .yellow
        case .housing: .brown
        case .subscriptions: .indigo
        case .other: .gray
        }
    }
}
#endif
