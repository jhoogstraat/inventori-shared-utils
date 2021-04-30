import Vapor
import JWT

public enum Role: String, Codable, CaseIterable { case user, admin }

public struct UserJWT: JWTPayload, Authenticatable {

    // User info
    let kid: String
    let user_id: UUID
    let role: Role
    
    // Claims
    var iss: IssuerClaim
    var iat: IssuedAtClaim
    var exp: ExpirationClaim
    
    public init(user_id: UUID, role: Role, key: String) {
        self.user_id = user_id
        self.kid = key
        self.role = role
        self.iss = "LITHAT"
        self.iat = .init(value: Date())
        self.exp = .init(value: .distantFuture)
    }

    /// Verifies any claims. Is called when Vapor converts the token string to a Payload
    public func verify(using signer: JWTSigner) throws {
        guard iss == "LITHAT" else {
            throw JWTError.claimVerificationFailure(name: "iss", reason: "Not matching")
        }

        try exp.verifyNotExpired()
    }
}
