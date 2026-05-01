import Foundation
import Domain

public struct SyncConfiguration: Sendable {
    public let baseURL: URL
    public let token: String

    public init(baseURL: URL, token: String) {
        self.baseURL = baseURL
        self.token = token
    }
}

public final class RemoteSyncService: RemoteSyncServiceProtocol, @unchecked Sendable {
    private let repo: ExpenseRepository
    private let config: SyncConfiguration?
    private let session: URLSession
    private let defaults: UserDefaults

    private static let lastSyncKey = "trackos.sync.lastSyncAt"

    public init(
        repo: ExpenseRepository,
        config: SyncConfiguration? = nil,
        session: URLSession = .shared,
        defaults: UserDefaults = .standard
    ) {
        self.repo = repo
        self.config = config
        self.session = session
        self.defaults = defaults
    }

    public func sync() async {
        guard let config else { return }
        let since = defaults.object(forKey: Self.lastSyncKey) as? Date ?? .distantPast

        do {
            let modified    = try await repo.fetchModified(since: since)
            let deletedIDs  = try await repo.fetchTombstoneIDs(since: since)

            let payload = SyncRequestBody(
                since: since,
                expenses: modified.map(SyncExpensePayload.init),
                deletedIDs: deletedIDs
            )

            let response = try await post(payload, to: config)

            let serverExpenses = response.expenses.map { r in
                SyncServerExpense(
                    id: r.id,
                    categoryID: r.categoryID,
                    amount: Decimal(r.amount),
                    currency: CurrencyCode(rawValue: r.currency.lowercased()) ?? .myr,
                    merchant: r.merchant,
                    note: r.note ?? "",
                    occurredAt: r.occurredAt,
                    updatedAt: r.updatedAt,
                    isDeleted: response.deletedIDs.contains(r.id)
                )
            }
            let deletedOnly = response.deletedIDs
                .filter { id in !response.expenses.contains { $0.id == id } }
                .map { id in
                    SyncServerExpense(id: id, categoryID: nil, amount: 0, currency: .myr,
                                      merchant: "", note: "", occurredAt: .now,
                                      updatedAt: nil, isDeleted: true)
                }

            try await repo.applyServerExpenses(serverExpenses + deletedOnly)
            try await repo.clearTombstones(ids: deletedIDs)
            defaults.set(response.serverTime, forKey: Self.lastSyncKey)
        } catch {
            // Offline-first: local data is authoritative when sync fails
        }
    }

    private func post(_ body: SyncRequestBody, to config: SyncConfiguration) async throws -> SyncResponseBody {
        var req = URLRequest(url: config.baseURL.appendingPathComponent("api/v1/sync"))
        req.httpMethod = "POST"
        req.setValue("Bearer \(config.token)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        req.httpBody = try encoder.encode(body)

        let (data, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(SyncResponseBody.self, from: data)
    }
}

// MARK: - Private Codable types

private struct SyncRequestBody: Encodable {
    let since: Date
    let expenses: [SyncExpensePayload]
    let deletedIDs: [UUID]
}

private struct SyncExpensePayload: Encodable {
    let id: UUID
    let categoryID: UUID?
    let amount: Double
    let currency: String
    let merchant: String
    let occurredAt: Date
    let source: String
    let note: String?

    init(_ e: Expense) {
        id = e.id
        categoryID = e.category?.id
        amount = NSDecimalNumber(decimal: e.amount).doubleValue
        currency = e.currencyRaw.uppercased()
        merchant = e.merchant
        occurredAt = e.occurredAt
        source = "manual"
        note = e.note.isEmpty ? nil : e.note
    }
}

private struct SyncResponseBody: Decodable {
    let expenses: [SyncExpenseItem]
    let deletedIDs: [UUID]
    let serverTime: Date
}

private struct SyncExpenseItem: Decodable {
    let id: UUID
    let categoryID: UUID?
    let amount: Double
    let currency: String
    let merchant: String
    let occurredAt: Date
    let source: String
    let note: String?
    let updatedAt: Date?
    let deletedAt: Date?
}
