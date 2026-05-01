import Vapor

// Request/response types for the API layer (separate from iOS Domain DTOs)

struct CreateExpenseRequest: Content {
    var id: UUID?           // client-generated for offline-first sync
    var categoryID: UUID?
    var amount: Double
    var currency: String
    var merchant: String
    var occurredAt: Date
    var source: String
    var note: String?
    var receiptURL: String?
}

struct ExpenseResponse: Content {
    var id: UUID
    var categoryID: UUID?
    var amount: Double
    var currency: String
    var merchant: String
    var occurredAt: Date
    var source: String
    var note: String?
    var receiptURL: String?
    var updatedAt: Date?
    var deletedAt: Date?
}

struct SyncRequest: Content {
    var since: Date
    var expenses: [CreateExpenseRequest]
    var deletedIDs: [UUID]
}

struct SyncResponse: Content {
    var expenses: [ExpenseResponse]
    var deletedIDs: [UUID]
    var serverTime: Date
}
