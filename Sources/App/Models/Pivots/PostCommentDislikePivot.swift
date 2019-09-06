//
//  PostCommentDislikePivot.swift
//  App
//
//  Created by Zaccari Silverman on 9/6/19.
//

import Vapor
import FluentPostgreSQL

struct PostCommentUserDislikePivot : PostgreSQLModel, ModifiablePivot {
    
    typealias Left = PostComment
    typealias Right = User
    
    static var leftIDKey: LeftIDKey = \.postCommentID
    static var rightIDKey: RightIDKey = \.userID
    
    var id: Int?
    var postCommentID: Int
    var userID: Int
    
    init(_ left: PostComment, _ right: User) throws {
        postCommentID = try left.requireID()
        userID = try right.requireID()
    }
    
}
//The migration associated with this model.
extension PostCommentUserDislikePivot: Migration {
    /// See `Migration`.
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return PostgreSQLDatabase.create(PostCommentUserDislikePivot.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            try addProperties(to: builder)
        }
    }
}
