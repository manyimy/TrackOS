import Vapor

// Receives signed webhook events from Plaid or a bank notification relay.
// Parses the event, creates a pending expense, and pushes an APNS notification.
struct WebhookController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.post("plaid", use: plaid)
    }

    // POST /webhooks/plaid
    func plaid(req: Request) async throws -> HTTPStatus {
        try verifySignature(req)
        let event = try req.content.decode(PlaidWebhookEvent.self)

        guard event.webhookType == "TRANSACTIONS",
              event.webhookCode == "TRANSACTIONS_REMOVED" || event.webhookCode == "DEFAULT_UPDATE"
        else { return .ok }

        // TODO: look up user via Plaid item_id → create Expense rows → push APNS
        req.logger.info("Plaid webhook received: \(event.webhookCode)")
        return .ok
    }

    private func verifySignature(_ req: Request) throws {
        guard let secret = Environment.get("PLAID_WEBHOOK_SECRET"),
              let sig = req.headers.first(name: "Plaid-Verification")
        else { throw Abort(.unauthorized) }
        // HMAC-SHA256 verification would go here
        _ = (secret, sig)
    }
}

struct PlaidWebhookEvent: Content {
    var webhookType: String
    var webhookCode: String
    var itemId: String?

    enum CodingKeys: String, CodingKey {
        case webhookType = "webhook_type"
        case webhookCode = "webhook_code"
        case itemId = "item_id"
    }
}
