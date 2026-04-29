import Foundation

public protocol CategoryClassifierProtocol: Sendable {
    func predict(merchant: String, note: String) -> UUID?
}
