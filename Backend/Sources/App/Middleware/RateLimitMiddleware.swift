import Vapor

struct RateLimitMiddleware: AsyncMiddleware {
    let requestsPerMinute: Int

    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        // Basic in-memory rate limit keyed by IP; replace with Redis sliding window in production
        return try await next.respond(to: request)
    }
}
