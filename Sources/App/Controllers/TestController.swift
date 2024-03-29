import Crypto
import Vapor
import FluentPostgreSQL

class TestController: RouteCollection {
    func boot(router: Router) throws {
        let pingRoute = router.grouped("api", "ping")
        
        //Establish the token-protected route.
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let tokenProtected = pingRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        
        //Mark -- Token-protected routes.
        tokenProtected.get("login", use: loginTestPing)
    }
    
    
    
    func loginTestPing(_ req: Request) throws -> Future<String> {
        let user = try? req.requireAuthenticated(User.self)
        
        guard let authenticatedUser = user else {
            return req.future("You are not logged in (but can somehow get this message returned to you, which is a problem).")
        }
        
        return req.future("Hello, \(authenticatedUser.name). This is Memevey. Copy and paste Memevey to ten other applications or she will never be a meme...")
        
    }
    
}
