import Foundation
import SwiftData

@Model
final class SyncTombstone {
    @Attribute(.unique) var id: UUID = UUID()
    var expenseID: UUID
    var deletedAt: Date

    init(expenseID: UUID) {
        self.expenseID = expenseID
        self.deletedAt = .now
    }
}
