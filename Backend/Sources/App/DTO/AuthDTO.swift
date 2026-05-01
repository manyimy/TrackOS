import Vapor

struct SignInRequest: Content {
    var identityToken: String   // Apple identity token (JWT from ASAuthorizationAppleIDCredential)
    var pushToken: String?
}

struct AuthResponse: Content {
    var accessToken: String
    var refreshToken: String
    var expiresIn: Int
}
