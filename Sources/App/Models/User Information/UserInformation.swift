//
//  UserInformation.swift
//  App
//
//  Created by Zaccari Silverman on 6/25/19.
//

import FluentPostgreSQL
import FluentPostGIS
import Vapor

/// A registered user, capable of owning todo items.
final class UserInformation: PostgreSQLModel {
    //MARK -- Variables and Initializer
    var id: Int?
    
    //The ID of the user this belongs to.
    var userID: User.ID
    
    //The name of this user.
    var name: String
    
    //The user this belongs to.
    var user: Parent<UserInformation, User> {
        return parent(\.userID)
    }
    
    //This user's location, as a PostGIS Geometric point.
    var location: GeographicPoint2D
    
    //Basic initializer.
    init(id: Int? = nil, forUser user: User, atLocation location: GeographicPoint2D) throws {
        self.id = id
        self.userID = try user.requireID()
        self.name = user.name
        self.location = location
    }
    
    //MARK -- Functions and helper structs/enums
    
    func distanceTo(otherUserInfo other: UserInformation, unit: DistanceUnitType) -> Double {
        func degreesToRadians(_ degrees: Double) -> Double {
            return degrees * .pi / 180
        }
        //Use the haversine function to calculate distance.
        let earthRadiusInMeters : Double = 6371000
        
        let deltaLat = degreesToRadians(other.location.latitude - self.location.latitude)
        let deltaLon = degreesToRadians(other.location.longitude - self.location.longitude)
        
        let myLatitudeRadians = degreesToRadians(self.location.latitude)
        let otherLatitudeRadians = degreesToRadians(other.location.latitude)
        
        //Unfortunately, these variables really are named a and c...
        let a = sin(deltaLat/2) * sin(deltaLat/2) +
                sin(deltaLon/2) * sin(deltaLon/2) * cos(myLatitudeRadians) * cos(otherLatitudeRadians)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        let distanceInMeters = earthRadiusInMeters * c
        
        //Return a converted value based on the unit type specified by the unit enum.
        switch unit {
        case .meters: return distanceInMeters
        case .kilometers: return distanceInMeters / 1000
        case .miles: return distanceInMeters / 1609.344
        }
        
    }
    
}


extension UserInformation: Migration {
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return PostgreSQLDatabase.create(UserInformation.self, on: conn) { builder in
            //builder.field(for: \.id, isIdentifier: true)
            //builder.field(for: \.userID)
            
            //builder.field(for: \.location)
            
            try addProperties(to: builder)
            builder.unique(on: \.id)
            builder.unique(on: \.userID)
        }
    }
}
