//
//  User+LikesDislikesInvolves.swift
//  App
//
//  Created by Zaccari Silverman on 9/6/19.
//

import Vapor
import FluentPostgreSQL

extension User {

    //For Posts
    var likedPosts : Siblings<User, Post, PostUserPivot>{
        return siblings(related: Post.self, through: PostUserPivot.self)
    }
    
    var dislikedPosts : Siblings<User, Post, PostUserPivot>{
        return siblings(related: Post.self, through: PostUserPivot.self)
    }
    
    var involvedPosts : Siblings<User, Post, PostUserPivot>{
        return siblings(related: Post.self, through: PostUserPivot.self)
    }
    
    //For comments
    
    var likedComments : Siblings<User, PostComment, PostCommentUserPivot>{
        return siblings(related: PostComment.self, through: PostCommentUserPivot.self)
    }
    
    var dislikedComments : Siblings<User, PostComment, PostCommentUserPivot>{
        return siblings(related: PostComment.self, through: PostCommentUserPivot.self)
    }
    
}
