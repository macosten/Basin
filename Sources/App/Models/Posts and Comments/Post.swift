
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
    
    //Created and Updated times, handled for us by Vapor (how kind!).
    static let createdAtKey: TimestampKey? = \.createdAt
    static let updatedAtKey: TimestampKey? = \.updatedAt
    
    var createdAt: Date?
    var updatedAt: Date?
    
    //We can use another date to track when an issue was marked as resolved.
    var resolvedAt: Date?
    
    
    //"Points" given by up/downs. These will track the general popularity of an idea.
    var likingUsers : Siblings<Post, User, PostUserPivot>{
        return siblings(related: User.self, through: PostUserPivot.self)
    }
    
    var dislikingUsers : Siblings<Post, User, PostUserPivot>{
        return siblings(related: User.self, through: PostUserPivot.self)
    }

    //The "Who wants to get involved in this idea?" group.
    var involvedUsers : Siblings<Post, User, PostUserPivot>{
        return siblings(related: User.self, through: PostUserPivot.self)
    }
    
    //Comments on a post.
    var comments : Children<Post, PostComment> {
        return children(\PostComment.id)
    }
    
    //The data sent to or from a client, as a struct.
    struct Public : Content {
        let id : Int?
        
        let userID : User.ID? // Don't necessarily require the userID when getting this from the client; we can get the user that's posting this from the fact that they're logged in with requireAuthenticated()
        
        let title : String
        
        let textContent : String
        //let pictureContent : ???
        //let videoContent : ???
        
        let createdAt: Date?
        let updatedAt: Date?
        let resolvedAt: Date?
        
        
        init(fromPost post: Post) {
            self.id = post.id
            self.title = post.title
            self.userID = post.userID
            self.textContent = post.textContent
            self.createdAt = post.createdAt
            self.updatedAt = post.updatedAt
            self.resolvedAt = post.resolvedAt
        }
    }
    
    //A convenience function to create a Post.Public from a Post.
    func publicize() -> Post.Public {
        return Post.Public(fromPost: self)
    }
    
    init(byUser user: User, fromIncomingPostPublic incomingPost: Post.Public) throws {
        self.userID = try user.requireID()
        self.title = incomingPost.title
        self.textContent = incomingPost.textContent
    }
    
}

//The migration associated with this model.
extension Post: Migration {
    /// See `Migration`.
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return PostgreSQLDatabase.create(Post.self, on: conn) { builder in
            try addProperties(to: builder)
        }
    }
}
