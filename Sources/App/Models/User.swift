import Authentication
import FluentPostgreSQL
import Vapor

/// A registered user, capable of owning todo items.
final class User: PostgreSQLModel {
    /// User's unique identifier.
    /// Can be `nil` if the user has not been saved yet.
    var id: Int?
    
    /// User's full name.
    var name: String
    
    /// User's email address.
    var email: String
    
    /// BCrypt hash of the user's password.
    var passwordHash: String
    
    /// Creates a new `User`.
    init(id: Int? = nil, name: String, email: String, passwordHash: String) {
        self.id = id
        self.name = name
        self.email = email
        self.passwordHash = passwordHash
    }
    
    //Mark -- Public user enum to be used in responses and the like.
    struct Response {
        let id: Int?
        let name: String
        let email: String
        
        init(from user: User) throws {
            self.id = try user.requireID()
            self.name = user.name
            self.email = user.email
        }
    }
}

/// Allows users to be verified by basic / password auth middleware.
/// Only use this when logging in to get a token!
extension User: PasswordAuthenticatable {
    /// See `PasswordAuthenticatable`.
    static var usernameKey: WritableKeyPath<User, String> {
        return \.email
    }
    
    /// See `PasswordAuthenticatable`.
    static var passwordKey: WritableKeyPath<User, String> {
        return \.passwordHash
    }
}

/// Allows users to be verified by bearer / token auth middleware.
extension User: TokenAuthenticatable {
    /// See `TokenAuthenticatable`.
    typealias TokenType = UserAccessToken
}

/// Allows `User` to be used as a Fluent migration.
extension User: Migration {
    /// See `Migration`.
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return PostgreSQLDatabase.create(User.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.name)
            builder.field(for: \.email)
            builder.field(for: \.passwordHash)
            //try addProperties(to: builder)
            builder.unique(on: \.email)
        }
    }
}
