import Vapor
import JWT

struct AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let auth = routes.grouped("auth")
        auth.post("signin", use: signIn)
        auth.post("refresh", use: refresh)
    }

    // POST /api/v1/auth/signin
    // Body: { identityToken, pushToken? }
    // Verifies Apple identity token, upserts user, returns JWT pair.
    func signIn(req: Request) async throws -> AuthResponse {
        let body = try req.content.decode(SignInRequest.self)

        // Verify Apple identity token
        let appleJWT = try await req.jwt.apple.verify(body.identityToken, applicationIdentifier: appleAppID(req))
        let appleSub = appleJWT.subject.value

        // Upsert user
        let user = try await User.query(on: req.db)
            .filter(\.$appleSub == appleSub)
            .first()
            ?? {
                let u = User(appleSub: appleSub, email: appleJWT.email)
                try await u.save(on: req.db)
                return u
            }()

        return try makeTokenPair(for: user, req: req)
    }

    // POST /api/v1/auth/refresh
    func refresh(req: Request) async throws -> AuthResponse {
        let payload = try await req.jwt.verify(as: UserPayload.self)
        guard let user = try await User.find(payload.userID, on: req.db) else {
            throw Abort(.unauthorized)
        }
        return try makeTokenPair(for: user, req: req)
    }

    private func makeTokenPair(for user: User, req: Request) throws -> AuthResponse {
        let userID = try user.requireID()
        let expiry = Date.now.addingTimeInterval(3600) // 1 hour
        let payload = UserPayload(sub: .init(value: user.appleSub), exp: .init(value: expiry), userID: userID)
        let token = try req.jwt.sign(payload)
        return AuthResponse(accessToken: token, refreshToken: token, expiresIn: 3600)
    }

    private func appleAppID(_ req: Request) -> String {
        Environment.get("APPLE_APP_ID") ?? "com.trackos.app"
    }
}
