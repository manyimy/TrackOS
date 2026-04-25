import XCTest
@testable import TrackOSCore

final class NotificationParserTests: XCTestCase {
    let parser = NotificationParserService()

    // MARK: - Amount Parsing

    func testParsesUSDDollarSign() throws {
        let result = try XCTUnwrap(parser.parse(text: "You've spent $42.50 at Starbucks"))
        XCTAssertEqual(result.amount, 42.50, accuracy: 0.001)
        XCTAssertEqual(result.currency, "USD")
    }

    func testParsesEuroSign() throws {
        let result = try XCTUnwrap(parser.parse(text: "Payment of €89.99 at H&M confirmed"))
        XCTAssertEqual(result.amount, 89.99, accuracy: 0.001)
        XCTAssertEqual(result.currency, "EUR")
    }

    func testParsesPoundSign() throws {
        let result = try XCTUnwrap(parser.parse(text: "£23.00 charged to your card at Pret"))
        XCTAssertEqual(result.amount, 23.00, accuracy: 0.001)
        XCTAssertEqual(result.currency, "GBP")
    }

    func testParsesThousandSeparator() throws {
        let result = try XCTUnwrap(parser.parse(text: "Payment of $1,234.56 at Apple Store"))
        XCTAssertEqual(result.amount, 1234.56, accuracy: 0.001)
    }

    func testReturnsNilWhenNoAmountFound() {
        XCTAssertNil(parser.parse(text: "Your package has been shipped successfully"))
    }

    // MARK: - Merchant Parsing

    func testExtractsMerchantAfterAt() throws {
        let result = try XCTUnwrap(parser.parse(text: "Chase: $150.00 charge at Amazon.com"))
        XCTAssertEqual(result.merchant, "Amazon.com")
    }

    func testExtractsMerchantAfterTo() throws {
        let result = try XCTUnwrap(parser.parse(text: "You sent $15.00 to Netflix"))
        XCTAssertFalse(result.merchant.isEmpty)
    }

    func testFallsBackToUnknownMerchant() throws {
        // Amount present but no extractable merchant
        let result = try XCTUnwrap(parser.parse(text: "$10.00 transaction"))
        XCTAssertEqual(result.merchant, "Unknown Merchant")
    }

    // MARK: - Category Inference

    func testInfersFoodCategory() throws {
        let result = try XCTUnwrap(parser.parse(text: "You spent $8.50 at McDonald's"))
        XCTAssertEqual(result.category, .food)
    }

    func testInfersGroceriesCategory() throws {
        let result = try XCTUnwrap(parser.parse(text: "$62.11 charged at Whole Foods"))
        XCTAssertEqual(result.category, .groceries)
    }

    func testInfersTransportCategory() throws {
        let result = try XCTUnwrap(parser.parse(text: "Uber trip: $12.30 charged to your card"))
        XCTAssertEqual(result.category, .transport)
    }

    func testInfersEntertainmentCategory() throws {
        let result = try XCTUnwrap(parser.parse(text: "Netflix subscription $15.99"))
        XCTAssertEqual(result.category, .entertainment)
    }

    func testDefaultsToOtherCategory() throws {
        let result = try XCTUnwrap(parser.parse(text: "$50.00 at Generic Store"))
        XCTAssertEqual(result.category, .other)
    }

    // MARK: - Full Notification

    func testParsesChaseFormat() throws {
        let result = try XCTUnwrap(
            parser.parse(
                notificationTitle: "Chase Sapphire",
                notificationBody: "$42.30 charge at Trader Joe's"
            )
        )
        XCTAssertEqual(result.amount, 42.30, accuracy: 0.001)
        XCTAssertEqual(result.category, .groceries)
    }
}
