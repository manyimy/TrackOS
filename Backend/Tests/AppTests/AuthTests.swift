import XCTVapor
@testable import App

final class AuthTests: XCTestCase {
    func testHealthCheck() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configure(app)

        try app.test(.GET, "health") { res in
            XCTAssertEqual(res.status, .ok)
        }
    }
}
