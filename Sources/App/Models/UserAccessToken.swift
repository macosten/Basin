import Authentication
import Crypto
import FluentPostgreSQL
import Vapor

/// An ephermal authentication token that identifies a registered user.
final class UserAccessToken: SQLiteModel {
    /// Creates a new `UserToken` for a given user.
    static func create(userID: User.ID) throws -> UserAccessToken {
        // generate a random 128-bit, base64-encoded string.
        let string = try CryptoRandom().generateData(count: 32).base64EncodedString()
        // init a new `UserToken` from that string.
        return .init(string: string, userID: userID)
    }
    
    /// See `Model`.
    static var deletedAtKey: TimestampKey? { return \.expiresAt }
    
    /// UserToken's unique identifier.
    var id: Int?
    
    /// Unique token string.
    var string: String
    
    /// Reference to user that owns this token.
    var userID: User.ID
    
    /// Expiration date. Token will no longer be valid after this point.
    var expiresAt: Date?
    
    /// Creates a new `UserToken`.
    init(id: Int? = nil, string: String, userID: User.ID) {
        self.id = id
        self.string = string
        // set token to expire after 5 hours
        self.expiresAt = Date.init(timeInterval: 60 * 60 * 5, since: .init())
        self.userID = userID
    }
}

extension UserAccessToken {
    /// Fluent relation to the user that owns this token.
    var user: Parent<UserAccessToken, User> {
        return parent(\.userID)
    }
}

/// Allows this model to be used as a TokenAuthenticatable's token.
extension UserAccessToken: Token {
    /// See `Token`.
    typealias UserType = User
    
    /// See `Token`.
    static var tokenKey: WritableKeyPath<UserAccessToken, String> {
        return \.string
    }
    
    /// See `Token`.
    static var userIDKey: WritableKeyPath<UserAccessToken, User.ID> {
        return \.userID
    }
}

/// Allows `UserToken` to be used as a Fluent migration.
extension UserAccessToken: Migration {
    /// See `Migration`.
    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
        return SQLiteDatabase.create(UserAccessToken.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.string)
            builder.field(for: \.userID)
            builder.field(for: \.expiresAt)
            builder.reference(from: \.userID, to: \User.id)
        }
    }
}

/// Allows `UserToken` to be encoded to and decoded from HTTP messages.
extension UserAccessToken: Content { }

/// Allows `UserToken` to be used as a dynamic parameter in route definitions.
extension UserAccessToken: Parameter { }
