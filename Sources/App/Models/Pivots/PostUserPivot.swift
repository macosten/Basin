//
//  PostUserLikePivot.swift
//  App
//
//  Created by Zaccari Silverman on 9/5/19.
//

import Vapor
import FluentPostgreSQL

//For Sibling relationships, pivots are required.
//This is basically just an object that acts as a link of sorts.
struct PostUserPivot : PostgreSQLModel, ModifiablePivot {
    
    typealias Left = Post
    typealias Right = User
    
    static var leftIDKey: LeftIDKey = \.postID
    static var rightIDKey: RightIDKey = \.userID
    
    var id: Int?
    var postID: Int
    var userID: Int
    
    var userLikesPost: Bool? //Nil for no relation, True for like, False for dislike
    var userInvolvedInPost: Bool //False for default (uninvolved), True for involved
    
    init(_ left: Post, _ right: User) throws {
        postID = try left.requireID()
        userID = try right.requireID()
        
        userInvolvedInPost = false
    }
    
}

//I've got different ones for each relationship type to make querying them a bit easier. Not sure if this is "correct".
//The migration associated with this model.
extension PostUserPivot: Migration {
    /// See `Migration`.
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return PostgreSQLDatabase.create(PostUserPivot.self, on: conn) { builder in
            try addProperties(to: builder)
        }
    }
}
