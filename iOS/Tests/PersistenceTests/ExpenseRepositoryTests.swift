import Testing
import Foundation
import SwiftData
@testable import Persistence
@testable import Domain

@Suite("ExpenseRepository")
struct ExpenseRepositoryTests {

    private func makeContainer() throws -> ModelContainer {
        let schema = Schema(TrackOSSchema.models)
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: config)
    }

    @Test("create and fetch round-trip")
    func createAndFetch() async throws {
        let container = try makeContainer()
        let repo = ExpenseRepository(modelContainer: container)

        let request = NewExpense(
            amount: Decimal(string: "15.90")!,
            currency: .myr,
            categoryID: nil,
            accountID: nil,
            merchant: "Nando's",
            note: "",
            occurredAt: Date()
        )
        try await repo.create(request)

        let start = Date().addingTimeInterval(-60)
        let end = Date().addingTimeInterval(60)
        let fetched = try await repo.fetch(in: DateInterval(start: start, end: end))
        #expect(fetched.count == 1)
        #expect(fetched.first?.merchant == "Nando's")
        #expect(fetched.first?.amount == Decimal(string: "15.90")!)
    }

    @Test("fetch returns only expenses in range")
    func fetchInRange() async throws {
        let container = try makeContainer()
        let repo = ExpenseRepository(modelContainer: container)

        let pastDate = Date().addingTimeInterval(-86_400 * 10) // 10 days ago
        let request = NewExpense(
            amount: 50,
            currency: .myr,
            categoryID: nil,
            accountID: nil,
            merchant: "OldShop",
            note: "",
            occurredAt: pastDate
        )
        try await repo.create(request)

        let recentStart = Date().addingTimeInterval(-60)
        let recentEnd = Date().addingTimeInterval(60)
        let recent = try await repo.fetch(in: DateInterval(start: recentStart, end: recentEnd))
        #expect(recent.isEmpty)
    }

    @Test("total aggregates amounts correctly")
    func totalAggregates() async throws {
        let container = try makeContainer()
        let repo = ExpenseRepository(modelContainer: container)

        let now = Date()
        for amount in [Decimal(10), Decimal(20), Decimal(30)] {
            try await repo.create(NewExpense(
                amount: amount, currency: .myr, categoryID: nil, accountID: nil,
                merchant: "Shop", note: "", occurredAt: now
            ))
        }

        let interval = DateInterval(start: now.addingTimeInterval(-60), end: now.addingTimeInterval(60))
        let total = try await repo.total(in: interval, categoryID: nil)
        #expect(total == 60)
    }

    @Test("delete removes expense")
    func deleteRemovesExpense() async throws {
        let container = try makeContainer()
        let repo = ExpenseRepository(modelContainer: container)

        let now = Date()
        try await repo.create(NewExpense(
            amount: 5, currency: .myr, categoryID: nil, accountID: nil,
            merchant: "Temp", note: "", occurredAt: now
        ))

        let interval = DateInterval(start: now.addingTimeInterval(-60), end: now.addingTimeInterval(60))
        let before = try await repo.fetch(in: interval)
        #expect(before.count == 1)

        try await repo.delete(id: before[0].id)

        let after = try await repo.fetch(in: interval)
        #expect(after.isEmpty)
    }
}
