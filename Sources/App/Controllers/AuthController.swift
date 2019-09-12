import Crypto
import Vapor
import FluentPostgreSQL

/// Creates new users and logs them in.
final class AuthController : RouteCollection {
    func boot(router: Router) throws {
        let authRoute = router.grouped("api", "auth")
        
        //Establish the unprotected route.
        authRoute.post("register", use: register)
        
        //Establish the basic-protected route. Only use this for logins.
        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCrypt)
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let basicProtected = authRoute.grouped(basicAuthMiddleware, guardAuthMiddleware) //We need guardAuthMiddlware so that bad requests are actually stopped.
        
        //Mark -- the only basic protected route.
        basicProtected.post("login", use: login)
        
        //Establish the token-protected route.
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let tokenProtected = authRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        
        //Mark -- Token-protected routes.
        tokenProtected.delete("login", use: logout)
        
    }
    
    /// Logs a user in, returning a token for accessing protected endpoints.
    func login(_ req: Request) throws -> Future<UserAccessToken.Wrapped> {
        // get user auth'd by basic auth middleware
        let user = try req.requireAuthenticated(User.self)
        
        // create new token for this user
        let token = try UserAccessToken.create(userID: user.requireID())
        
        // save and return token
        return token.save(on: req).map { token in
            return UserAccessToken.Wrapped(from: token)
        }
    }
    
    /// Creates a new user.
    func register(_ req: Request) throws -> Future<HTTPResponse> {
        // decode request content
        return try req.content.decode(CreateUserRequest.self).flatMap { user -> Future<User> in
            // perform all appropriate validations. See CreateUserRequest.validations().
            try user.validate()
     
            // hash user's password using BCrypt
            let hash = try BCrypt.hash(user.password)
            // save new user
            return User(id: nil, name: user.name, email: user.email, passwordHash: hash)
                .save(on: req)
        }.returnOkay()
    }
    
    func logout(_ req: Request) throws -> Future<HTTPResponse> {
        //Let the user get auth'd and get that user.
        let user = try req.requireAuthenticated(User.self)
        //Delete all of the tokens that belong to this user.
        //Note that if you want to just log out from one device, you should have that device merely delete its own tokens. The access tokens themselves should expire after a while anyway.
        return try UserAccessToken.query(on: req)
                .filter(\.userID, .equal, user.requireID()).delete()
                .returnOkay()
        
    }
    
    
}
