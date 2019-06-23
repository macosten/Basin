import Crypto
import Vapor
import FluentPostgreSQL

/// Creates new users and logs them in.
final class AuthController : RouteCollection {
    func boot(router: Router) throws {
        let authRoute = router.grouped("api", "auth")
        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCrypt)
        
        authRoute.post(<#T##path: PathComponentsRepresentable...##PathComponentsRepresentable#>, use: <#T##(Request) throws -> ResponseEncodable#>)
        
        
    }
}


extension AuthController {
    /// Logs a user in, returning a token for accessing protected endpoints.
    func login(_ req: Request) throws -> Future<UserAccessToken> {
        // get user auth'd by basic auth middleware
        let user = try req.requireAuthenticated(User.self)
        
        // create new token for this user
        let token = try UserAccessToken.create(userID: user.requireID())
        
        // save and return token
        return token.save(on: req)
    }
    
    /// Creates a new user.
    func register(_ req: Request) throws -> Future<User.Response> {
        // decode request content
        return try req.content.decode(CreateUserRequest.self).flatMap { user -> Future<User> in
            // verify that passwords match
            guard user.password == user.verifyPassword else {
                throw Abort(.badRequest, reason: "Password and verification must match.")
            }
            
            // hash user's password using BCrypt
            let hash = try BCrypt.hash(user.password)
            // save new user
            return User(id: nil, name: user.name, email: user.email, passwordHash: hash)
                .save(on: req)
            }.map { user in
                // map to public user response (omits password hash)
                return try User.Response(from: user)
        }
    }
}

// MARK: Content

/// Data required to create a user.
struct CreateUserRequest: Content {
    /// User's full name.
    var name: String
    
    /// User's email address.
    var email: String
    
    /// User's desired password.
    var password: String
    
    /// User's password repeated to ensure they typed it correctly.
    var verifyPassword: String
}

