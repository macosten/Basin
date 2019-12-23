
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
    
    var username : String // I'm still going to keep track of the name of the user posting this.
    //If they choose to change their name at a later time, it might be worth just running an operation
    //on all posts they own that changes this property.
    
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
    
    //The data sent to a client, as a struct.
    struct Public : Content {
        let id : Int?
        
        let userID : User.ID
        
        let username : String
        
        let title : String
        
        let textContent : String
        //let pictureContent : ???
        //let videoContent : ???
        
        // TODO: -- Implement this on the client side.
        let createdAt: Date?
        let updatedAt: Date?
        //let resolvedAt: Date?
        
        
        init(fromPost post: Post) {
            self.id = post.id
            self.title = post.title
            self.userID = post.userID
            self.username = post.username
            self.textContent = post.textContent
            self.createdAt = post.createdAt
            self.updatedAt = post.updatedAt
            //self.resolvedAt = post.resolvedAt
        }
    }
    
    //The data sent from a client.
    struct Incoming : Content {
        let id : Int?
        
        let userID : User.ID?
        
        let title : String?
        //All of these are optional to allow the more intuitive use of PATCH for the URL method that edits a post.
        
        let textContent : String?
        //let pictureContent : ???
        //let videoContent : ???
        
        let resolvedAt: Date?
        
        init(fromPost post: Post) {
            self.id = post.id
            self.title = post.title
            self.userID = post.userID
            self.textContent = post.textContent
            self.resolvedAt = post.resolvedAt
        }
    }
    
    //A convenience function to create a Post.Public from a Post.
    func publicize() -> Post.Public {
        return Post.Public(fromPost: self)
    }
    
    init(byUser user: User, fromIncomingPost incomingPost: Post.Incoming) throws {
        self.userID = try user.requireID()
        
        //Check that the incoming title and text content exist; for now, they're the only things that are 100% necessary.
        guard let incomingTitle = incomingPost.title else { throw Abort(.badRequest, reason: "A new post needs a title.") }
        
        guard let incomingTextContent = incomingPost.textContent else { throw Abort(.badRequest, reason: "A new post needs test content.") }
        
        self.title = incomingTitle
        self.username = user.name
        self.textContent = incomingTextContent
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
