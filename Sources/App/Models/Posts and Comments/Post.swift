
//
//  File.swift
//  App
//
//  Created by Zaccari Silverman on 9/5/19.
//

import Vapor
import FluentPostgreSQL

final class Post : PostgreSQLModel {
    var id: Int?
    
    //Basic post information.
    var title : String
    
    //The ID of the user that posted this...
    var userID : User.ID
    //...so we can find that user like this.
    var user : Parent<Post, User> {
        return parent(\.userID)
    }
    
    //Content of a post -- this is subject to the most change.
    //var hyperlinkContent : String?
    var textContent : String
    //var pictureContent : URL?
    //var videoContent : URL?
    
    //"Points" given by up/downs. These will track the general popularity of an idea.
    var likingUsers : Siblings<Post, User, PostUserLikePivot>{
        return siblings(related: User.self, through: PostUserLikePivot.self)
    }
    
    var dislikingUsers : Siblings<Post, User, PostUserDislikePivot>{
        return siblings(related: User.self, through: PostUserDislikePivot.self)
    }

    //The "Who wants to get involved in this idea?" group.
    var involvedUsers : Siblings<Post, User, PostUserInvolvePivot>{
        return siblings(related: User.self, through: PostUserInvolvePivot.self)
    }
    
    //Comments on a post.
    var comments : Children<Post, PostComment> {
        return children(\PostComment.id)
    }
    
}

//The migration associated with this model.
extension Post: Migration {
    /// See `Migration`.
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return PostgreSQLDatabase.create(Post.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            try addProperties(to: builder)
        }
    }
}
