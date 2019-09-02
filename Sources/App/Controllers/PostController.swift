import Crypto
import Vapor
import FluentPostgreSQL

class PostController: RouteCollection {
    func boot(router: Router) throws {
        let mainRoute = router.grouped("api", "match")

        //Establish the token-protected route.
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let tokenProtected = mainRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        
        //Mark -- Token-protected routes.

    }
    
}

