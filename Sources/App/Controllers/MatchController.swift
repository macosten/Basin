import Crypto
import Vapor
import FluentPostgreSQL
import FluentPostGIS

class MatchController: RouteCollection {
    func boot(router: Router) throws {
        let mainRoute = router.grouped("api", "match")
        
        //Establish the token-protected route.
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let tokenProtected = mainRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        
        //Mark -- Token-protected routes.
        tokenProtected.get("fetch", use: theMatchingFunction)
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
        }.flatMap { info in
            //Query the userinfo database for all userinfos whose user is within the search distance.
            //We also want to pass along the current UserInfo, so let's do that.
            return UserInformation.query(on: req).filterGeometryDistanceWithin(\UserInformation.location, info.location, searchDistance).all().and(result: info)
        }.map(to: [PublicUserInformation].self) { infoForNearbyUsers, myInfo in
            
            var matchingUsers = [PublicUserInformation]()
            
            //For each userinfo in the pool of users...
            for nearbyUserInfo in infoForNearbyUsers {
                //...add that user's ID to the list of users we will return, because that's really all we're doing for now.
                //Later on, what we do will become more complicated.
                
                let distance = myInfo.distanceTo(otherUserInfo: nearbyUserInfo, unit: .kilometers) //Eventually, the .kilometers here will be set by the user rather than hardcoded.
                
                let publicInfo = PublicUserInformation(fromUserInfo: nearbyUserInfo, distance: distance)
                
                matchingUsers.append(publicInfo)
            }
            //In the future, we may also want to sort these somehow, and in fact we probably will. For now, we won't...
            return matchingUsers
        }
        
    }
    
}

