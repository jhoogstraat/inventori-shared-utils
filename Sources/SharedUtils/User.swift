import Vapor
import JWT

public enum Role: String, Codable, CaseIterable { case user, admin }

public struct UserJWT: JWTPayload, Authenticatable {

    // User info
    public let user_id: UUID
    public let role: Role
    
    // Claims
    public let kid: String
    public let iss: IssuerClaim
    public let iat: IssuedAtClaim
    public let exp: ExpirationClaim
    
    public init(userId: UUID, role: Role, key: String) {
        self.user_id = userId
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
