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

    // MARK: - MYR / CNY / Asian Currencies

    func testParsesMYRRMSymbol() throws {
        let result = try XCTUnwrap(parser.parse(text: "Maybank: RM12.50 charged at Jaya Grocer"))
        XCTAssertEqual(result.amount, 12.50, accuracy: 0.001)
        XCTAssertEqual(result.currency, "MYR")
    }

    func testParsesMYRRMSymbolNoSpace() throws {
        let result = try XCTUnwrap(parser.parse(text: "Touch 'n Go: RM5.20 deducted at parking"))
        XCTAssertEqual(result.amount, 5.20, accuracy: 0.001)
        XCTAssertEqual(result.currency, "MYR")
    }

    func testParsesMYRISOCode() throws {
        let result = try XCTUnwrap(parser.parse(text: "Payment of 250.00 MYR to Shopee confirmed"))
        XCTAssertEqual(result.amount, 250.00, accuracy: 0.001)
        XCTAssertEqual(result.currency, "MYR")
    }

    func testParsesCNYISOCode() throws {
        let result = try XCTUnwrap(parser.parse(text: "Alipay: 99.00 CNY at Taobao"))
        XCTAssertEqual(result.amount, 99.00, accuracy: 0.001)
        XCTAssertEqual(result.currency, "CNY")
    }

    func testParsesCNYRMBPrefix() throws {
        let result = try XCTUnwrap(parser.parse(text: "WeChat Pay: RMB88.00 at Hema"))
        XCTAssertEqual(result.amount, 88.00, accuracy: 0.001)
        XCTAssertEqual(result.currency, "CNY")
    }

    func testParsesJPYYenSymbol() throws {
        let result = try XCTUnwrap(parser.parse(text: "¥1200 charged at 7-Eleven Japan"))
        XCTAssertEqual(result.amount, 1200, accuracy: 0.001)
        XCTAssertEqual(result.currency, "JPY")
    }

    func testParsesSGDSymbol() throws {
        let result = try XCTUnwrap(parser.parse(text: "DBS: S$18.50 at Grab Singapore"))
        XCTAssertEqual(result.amount, 18.50, accuracy: 0.001)
        XCTAssertEqual(result.currency, "SGD")
    }

    // MARK: - Malaysian Merchant Category Inference

    func testInfersGrabAsTransport() throws {
        let result = try XCTUnwrap(parser.parse(text: "Grab: RM14.00 GrabCar ride completed"))
        XCTAssertEqual(result.category, .transport)
    }

    func testInfersGrabFoodAsFood() throws {
        let result = try XCTUnwrap(parser.parse(text: "GrabFood order RM22.90 delivered"))
        XCTAssertEqual(result.category, .food)
    }

    func testInfersShopeeAsShopping() throws {
        let result = try XCTUnwrap(parser.parse(text: "Shopee payment RM35.00 confirmed"))
        XCTAssertEqual(result.category, .shopping)
    }

    func testInfersJayaGrocerAsGroceries() throws {
        let result = try XCTUnwrap(parser.parse(text: "RM67.80 at Jaya Grocer TTDI"))
        XCTAssertEqual(result.category, .groceries)
    }

    func testInfersTNBAsUtilities() throws {
        let result = try XCTUnwrap(parser.parse(text: "TNB bill payment RM120.00 successful"))
        XCTAssertEqual(result.category, .utilities)
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
