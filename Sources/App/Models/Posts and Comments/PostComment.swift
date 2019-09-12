//
//  PostComment.swift
//  App
//
//  Created by Zaccari Silverman on 9/5/19.
//

import Vapor
import FluentPostgreSQL

final class PostComment : PostgreSQLModel {
    var id : Int?
    
    //Posting User Information
    var userID : User.ID
    var user : Parent<PostComment, User> {
        return parent(\.userID)
    }
    
    //Post Information
    var parentPostID : Post.ID
    var parentPost : Parent<PostComment, Post> {
        return parent(\.parentPostID)
    }
    
    //Idea: Comment chains. I'll leave this here, for later development.
    //Parent Comment Information
    var parentCommentID : PostComment.ID?
    var parentComment: Parent<PostComment, PostComment>? {
        return parent(\.parentCommentID)
    }
    
    // MARK -- Content
    var textContent : String
    
    //Update and Creation times
    static let createdAtKey: TimestampKey? = \.createdAt
    static let updatedAtKey: TimestampKey? = \.updatedAt
    
    var createdAt: Date?
    var updatedAt: Date?
    
    // MARK -- Points/Likes/Dislikes
    var likingUsers : Siblings<PostComment, User, PostCommentUserPivot>{
        return siblings(related: User.self, through: PostCommentUserPivot.self)
    }
    
    var dislikingUsers : Siblings<PostComment, User, PostCommentUserPivot>{
        return siblings(related: User.self, through: PostCommentUserPivot.self)
    }

}


//The migration associated with this model.
extension PostComment: Migration {
    /// See `Migration`.
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return PostgreSQLDatabase.create(PostComment.self, on: conn) { builder in
            //builder.field(for: \.id, isIdentifier: true) //addProperties already dows this. If it breaks, add them all manually using the builder.field() methods.
            try addProperties(to: builder)
        }
    }
}
