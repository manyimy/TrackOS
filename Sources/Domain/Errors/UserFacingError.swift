import Foundation

public struct UserFacingError: LocalizedError, Sendable {
    public let title: String
    public let message: String

    public var errorDescription: String? { message }

    public init(title: String, message: String) {
        self.title = title
        self.message = message
    }

    public init(from error: Error) {
        if let domain = error as? DomainError {
            switch domain {
            case .invalidAmount:
                self.init(title: "Invalid Amount",
                          message: "Please enter an amount greater than zero.")
            case .invalidMerchant:
                self.init(title: "Missing Merchant",
                          message: "Please enter a merchant name.")
            case .fxUnavailable:
                self.init(title: "Exchange Rate Unavailable",
                          message: "Could not fetch the exchange rate. Please try again.")
            case .budgetNotFound:
                self.init(title: "Budget Not Found",
                          message: "The requested budget could not be found.")
            case .expenseNotFound:
                self.init(title: "Expense Not Found",
                          message: "The requested expense could not be found.")
            case .categoryNotFound:
                self.init(title: "Category Not Found",
                          message: "The requested category could not be found.")
            }
        } else {
            self.init(title: "Something Went Wrong",
                      message: error.localizedDescription)
        }
    }
}
