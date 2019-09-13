import Crypto
import Vapor
import FluentPostgreSQL

class PostController: RouteCollection {
    func boot(router: Router) throws {
        let mainRoute = router.grouped("api", "match")

        //Establish the token-protected route.
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let tokenProtected = mainRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        
        //Mark -- Token-protected routes.
        tokenProtected.get("post", "listActivePosts", use: listActivePosts)
        tokenProtected.get("post", "listAllPosts", use: listAllPosts)
        tokenProtected.get("post", "listResolvedPosts", use: listResolvedPosts)
        
        tokenProtected.post("post", "createPost", use: createPost)
        tokenProtected.patch("post", "editPost", use: editPost)
        tokenProtected.patch("post", "markPostAsUnresolved", use: markPostAsUnresolved)
        tokenProtected.delete("post", "deletePost", use: deletePost)
        
    }
    
    
    func listActivePosts(_ req: Request) throws -> Future<[Post.Public]> {
        return try req.content.decode(ListPostsRequest.self).flatMap(to: [Post].self){ listPostsRequest in
            return Post.query(on: req).filter(\.resolvedAt == nil).sort(\.id, .descending)
                .range(listPostsRequest.startIndex..<listPostsRequest.count).all() //Take [count] posts, starting at the [startIndex]-th, only including ones that haven't been marked as resolved.
            
        }.map(to: [Post.Public].self) { postArray in //Then convert all these posts to the public representation.
            var publicPosts = [Post.Public]()
            publicPosts.reserveCapacity(postArray.count) //Probably not a necessary line...
            
            postArray.forEach { publicPosts.append($0.publicize()) } //Append the public version of each post to the publicPosts array.
            
            return publicPosts //Return the posts.
        }
    }
    
    func listAllPosts(_ req: Request) throws -> Future<[Post.Public]> {
        return try req.content.decode(ListPostsRequest.self).flatMap(to: [Post].self){ listPostsRequest in
            return Post.query(on: req).sort(\.id, .descending)
                .range(listPostsRequest.startIndex..<listPostsRequest.count).all() //Take [count] posts, starting at the [startIndex]-th.
            
            }.map(to: [Post.Public].self) { postArray in //Then convert all these posts to the public representation.
                var publicPosts = [Post.Public]()
                publicPosts.reserveCapacity(postArray.count) //Probably not a necessary line...
                
                postArray.forEach { publicPosts.append($0.publicize()) } //Append the public version of each post to the publicPosts array.
                
                return publicPosts //Return the posts.
        }
    }
    
    func listResolvedPosts(_ req: Request) throws -> Future<[Post.Public]> {
        return try req.content.decode(ListPostsRequest.self).flatMap(to: [Post].self){ listPostsRequest in
            return Post.query(on: req).filter(\.resolvedAt != nil).sort(\.id, .descending)
                .range(listPostsRequest.startIndex..<listPostsRequest.count).all() //Take [count] posts, starting at the [startIndex]-th, only listing posts marked as resolved.
            
            }.map(to: [Post.Public].self) { postArray in //Then convert all these posts to the public representation.
                var publicPosts = [Post.Public]()
                publicPosts.reserveCapacity(postArray.count) //Probably not a necessary line...
                
                postArray.forEach { publicPosts.append($0.publicize()) } //Append the public version of each post to the publicPosts array.
                
                return publicPosts //Return the posts.
        }
    }
    
    //Create a post.
    func createPost(_ req: Request) throws -> Future<Status> {
        let user = try req.requireAuthenticated(User.self) //Get the user posting this.
        
        return try req.content.decode(Post.Incoming.self).flatMap(to: Post.self) { incomingPost in
            //See the designated initializer in Post.swift to modify this.
            let newPost = try Post(byUser: user, fromIncomingPost: incomingPost)
            return newPost.save(on: req)
        }.returnOkayStatus() //For now, just return a dumb okay status. Something more useful can be implemented later...
        
    }
    
    //Edit an existing post.
    func editPost(_ req: Request) throws -> Future<Status> {
        //This is how we'll edit a post in almost any way -- except it's not how we'll unresolve a resolved post. That (for now) will use a different method, but this can potentially be changed.
        let user = try req.requireAuthenticated(User.self) //Get the user attempting to edit a post.
        
        return try req.content.decode(Post.Incoming.self).flatMap(to: (Post?, Post.Incoming).self) { incomingPost in
            //The .id field should be filled out to specify the post we actually want to modify.
            guard let getID = incomingPost.id else {
                throw Abort(.badRequest, reason: "A database ID was not specified, so the post cannot be found.")
            }
            
            //Look for a post with that ID.
            return Post.find(getID, on: req).and(result: incomingPost)
        }.flatMap(to: Post.self){ postOptional, incomingPost in
            //Check the user's ability to edit this post.
            let post = try self.checkUserCanEditPostOptional(user, forEditingPostOptional: postOptional)
            
            //Now, all of our checks should be complete. We will begin modifying the post itself now.
            
            //Should we allow people to edit titles? For now, we will; if not, delete this line.
            if let incomingTitle = incomingPost.title { post.title = incomingTitle }
            
            //Now, let's actually edit the textContent, if it was specified.
            if let incomingText = incomingPost.textContent { post.textContent = incomingText }
            
            //Now, if a resolvedAt date is specified, mark the post as resolved.
            if let incomingResolvedAt = incomingPost.resolvedAt { post.resolvedAt = incomingResolvedAt }
            
            //Note that createdAt and updatedAt are all handled by Fluent, so we won't touch them.
            
            //We don't want User.ID to be modified (for now -- in the future, this might be good to "hand off" a task post to another person).
            
            //Save the post now.
            return post.save(on: req)
        }.returnOkayStatus() //Return the dumb Okay Status for now.
    }
    
    func markPostAsUnresolved(_ req: Request) throws -> Future<Status>{
        //This is meant to be a method to erase a Post's resolvedAt date, in case of a mistake or something.
        
        let user = try req.requireAuthenticated(User.self) //Get the user attempting to modify the post.
        
        return try req.content.decode(Post.Incoming.self).flatMap(to: (Post?, Post.Incoming).self) { incomingPost in
            //The .id field should be filled out to specify the post we actually want to modify.
            guard let getID = incomingPost.id else {
                throw Abort(.badRequest, reason: "A database ID was not specified, so the post cannot be found.")
            }
            
            //Look for a post with that ID.
            return Post.find(getID, on: req).and(result: incomingPost)
            }.flatMap(to: Post.self){ postOptional, incomingPost in
                //Check the user's ability to edit this post.
                let post = try self.checkUserCanEditPostOptional(user, forEditingPostOptional: postOptional)
                
                //If we're here, then the above method didn't throw and abort, so we'll set the post's resolvedAt to nil.
                post.resolvedAt = nil
                
                return post.save(on: req)
        }.returnOkayStatus()
    }
    
    func deletePost(_ req: Request) throws -> Future<Status>{
        //Permanently delete a post. This isn't really something that probably *needs* to happen often, but it's here for completion's sake.
        let user = try req.requireAuthenticated(User.self) //Get the user attempting to modify the post.
        
        return try req.content.decode(Post.Incoming.self).flatMap(to: (Post?, Post.Incoming).self) { incomingPost in
            //The .id field should be filled out to specify the post we actually want to modify.
            guard let getID = incomingPost.id else {
                throw Abort(.badRequest, reason: "A database ID was not specified, so the post cannot be found.")
            }
            
            //Look for a post with that ID.
            return Post.find(getID, on: req).and(result: incomingPost)
            }.flatMap(to: Void.self) { postOptional, incomingPost in
                //Check the user's ability to edit this post.
                let post = try self.checkUserCanEditPostOptional(user, forEditingPostOptional: postOptional)
                
                //If we're here, then the above method didn't throw and abort, so we'll delete the post immediately.
                return post.delete(on: req)
            }.returnOkayStatus()
    }
    
    
    
    
}


// MARK -- Non-route methods
extension PostController {
    
    //Check to see if the passed-in user can edit the post. To be used in methods that want to edit a post somehow.
    func checkUserCanEditPostOptional(_ user: User, forEditingPostOptional postOptional: Post?) throws -> Post {
        //Make sure we found the post.
        guard let post = postOptional else { throw Abort(.notFound, reason: "A post with that database ID was not found.") }
        
        //A user may only edit their own posts.
        if post.userID != user.id { throw Abort(.unauthorized, reason: "You cannot edit someone else's posts.") }
        
        
        //If we're authorized to edit the post, we'll return it.
        return post
    }
}
