import Crypto
import Vapor
import FluentPostgreSQL



class EditUserInfoController: RouteCollection {
    func boot(router: Router) throws {
        let mainRoute = router.grouped("api", "info")
        
        //Establish the token-protected route.
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let tokenProtected = mainRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        
        //MARK -- Token-protected routes.
        tokenProtected.patch("patch", use: patchInfo)
    }
    
    func patchInfo(_ req: Request) throws -> Future<Status> {
        //Get the user requesting to change their info.
        let user = try req.requireAuthenticated(User.self)
        
        return try user.info.query(on: req).first().map(to: Status.self) { info in
            //If info doesn't exist, it should be created... but for now, we'll just fail.
            return Status(status: "This hasn't been fully implemented yet.")
        }
        
    }
    
}
