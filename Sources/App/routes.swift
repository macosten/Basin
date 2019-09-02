import Crypto
import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    let authController = AuthController()
    try authController.boot(router: router)
    
    let testController = TestController()
    try testController.boot(router: router)
    
    let postController = PostController()
    try postController.boot(router: router)
    
}
