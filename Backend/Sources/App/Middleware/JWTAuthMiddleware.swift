import Vapor
import JWT

struct JWTAuthMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        let payload = try await request.jwt.verify(as: UserPayload.self)
        request.storage[UserPayloadKey.self] = payload
        return try await next.respond(to: request)
    }
}

struct UserPayload: JWTPayload {
    var sub: SubjectClaim
    var exp: ExpirationClaim
    var userID: UUID

    func verify(using key: some JWTAlgorithm) async throws {
        try exp.verifyNotExpired()
    }
}

private struct UserPayloadKey: StorageKey {
    typealias Value = UserPayload
}

extension Request {
    var userPayload: UserPayload {
        get throws {
            guard let payload = storage[UserPayloadKey.self] else {
                throw Abort(.unauthorized)
            }
            return payload
        }
    }
}
