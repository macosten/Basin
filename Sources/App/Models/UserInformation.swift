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
    var id: Int?
    
    //The ID of the user this belongs to.
    var userID: User.ID
    
    //The user this belongs to.
    var user: Parent<UserInformation, User> {
        return parent(\.userID)
    }
    
    var location: GeographicPoint2D?
    
    //Basic initializer.
    init(id: Int? = nil, forUserWithID userID: User.ID) {
        self.id = id
        
        self.userID = userID
    }
    
    
    
    
}


extension UserInformation: Migration {
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return PostgreSQLDatabase.create(UserInformation.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.userID)
            
            builder.field(for: \.location)
            
            try addProperties(to: builder)
            builder.unique(on: \.id)
            builder.unique(on: \.userID)
        }
    }
}
