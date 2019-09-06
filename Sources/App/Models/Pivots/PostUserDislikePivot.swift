//
//  PostUserDislikePivot.swift
//  App
//
//  Created by Zaccari Silverman on 9/5/19.
//

import Vapor
import FluentPostgreSQL

//For Sibling relationships, pivots are required.
//This is basically just an object that acts as a link of sorts.
struct PostUserDisikePivot : PostgreSQLModel, ModifiablePivot {
    
    var id: Int?
    var postID: Int
    var userID: Int
    
    
    init(_ left: Post, _ right: User) throws {
        postID = try left.requireID()
        userID = try right.requireID()
    }
    
    typealias Left = Post
    typealias Right = User
    
    static var leftIDKey: LeftIDKey = \.postID
    static var rightIDKey: RightIDKey = \.userID
    
}
