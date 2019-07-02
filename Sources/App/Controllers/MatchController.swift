import Crypto
import Vapor
import FluentPostgreSQL
import FluentPostGIS

class MatchController: RouteCollection {
    func boot(router: Router) throws {
        let pingRoute = router.grouped("api", "match")
        
        //Establish the token-protected route.
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let tokenProtected = pingRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        
        //Mark -- Token-protected routes.
        //TokenProtected.get("fetch", use: theMatchingFunction)
    }
    
    //The Algorithm...
    func theMatchingFunction(_ req: Request) throws -> Future<[PublicUserInformation]> {
        //Get the user requesting their matches.
        let user = try req.requireAuthenticated(User.self)
        
        let searchDistance = 1000.0
        
        
        
        return try user.info.query(on: req).first().map(to: UserInformation.self) { userInfo in
            //Attempt to get this user's info. If we can't, likely because it doesn't exist, Abort.
            guard let info = userInfo else {
                throw Abort(.internalServerError, reason: "A user info object for you could not be found. Have you filled out your information? [theMatchingFunction]")
            }
            return info //We then pass the info on to the next part of this chain.
        }.flatMap(to: [UserInformation].self) { info in
            //Query the userinfo database for all userinfos whose user is within the search distance.
            return UserInformation.query(on: req).filterGeometryDistanceWithin(\UserInformation.location, info.location, searchDistance).all()
        }.map(to: [PublicUserInformation].self) { infoForNearbyUsers in
            
            var matchingUsers = [PublicUserInformation]()
            
            //For each userinfo in the pool of users...
            for userInfo in infoForNearbyUsers {
                //...add that user's ID to the list of users we will return, because that's really all we're doing for now.
                //Later on, what we do will become more complicated.
                let publicInfo = PublicUserInformation(fromUserInfo: userInfo, distance: 0)
                matchingUsers.append(publicInfo)
            }
            //In the future, we may also want to sort these somehow, and in fact we probably will. For now, we won't...
            return matchingUsers
        }
        //Potential addition: "Look for people within a distance of ___" -- for now, this will be hardcoded or something
        
        
        
        //Query every user within their user's preference
   
        
    }
    
}

