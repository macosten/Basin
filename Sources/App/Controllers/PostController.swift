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
        tokenProtected.get("listActivePosts", use: listActivePosts)
        tokenProtected.get("listAllPosts", use: listAllPosts)
        tokenProtected.get("listResolvedPosts", use: listResolvedPosts)
        
        tokenProtected.post("createPost", use: createPost)
        tokenProtected.put("editPost", use: editPost)
        
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
              
                let publicPosts =  postArray.map{ $0.publicize() } //Map the Posts to Post.Publics.
                return publicPosts //Return the posts.
        }
    }
    
    //Create a post.
    func createPost(_ req: Request) throws -> Future<HTTPResponse> {
        let user = try req.requireAuthenticated(User.self) //Get the user posting this.
        
        return try req.content.decode(Post.Public.self).flatMap(to: Post.self) { incomingPost in
            //See the designated initializer in Post.swift to modify this.
            let newPost = try Post(byUser: user, fromIncomingPostPublic: incomingPost)
            return newPost.save(on: req)
        }.returnOkay() //For now, just return a dumb okay status. Something more useful can be implemented later...
        
    }
    
    //Edit an existing post.
    func editPost(_ req: Request) throws -> Future<HTTPResponse> {
        let user = try req.requireAuthenticated(User.self) //Get the user attempting to edit a post.
        
        return try req.content.decode(Post.Public.self).flatMap(to: (Post?, Post.Public).self) { incomingPost in
            //The .id field should be filled out to specify the post we actually want to modify.
            guard let getID = incomingPost.id else {
                throw Abort(.badRequest, reason: "A database ID was not specified, so the post cannot be found.")
            }
            
            //Look for a post with that ID.
            return Post.find(getID, on: req).and(result: incomingPost)
        }.flatMap(to: Post.self){ postOptional, incomingPost in
            //Make sure we found the post.
            guard let post = postOptional else {
                throw Abort(.notFound, reason: "A post with that database ID was not found.")
            }
            
            //A user may only edit their own posts.
            if post.userID != user.id {
                throw Abort(.unauthorized, reason: "You cannot edit someone else's posts.")
            }
            
            //Do we want titles to be edited?
            //post.title = incomingPost.title
            
            //After all these checks, let's actually edit the textContent.
            post.textContent = incomingPost.textContent
            
            //Save the post now.
            return post.save(on: req)
        }.returnOkay() //Return the dumb Okay Status for now.
    }
    
    
    
    //func markPostAsResolved(){} //Take in a Post.ID, and if the requesting user posted this post, then mark this post as resolved by adding the resolvedAt date.
    
    //func deletePost(){} //Permanently delete a post.
    
    
}
