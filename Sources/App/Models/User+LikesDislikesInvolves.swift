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
    var likedPosts : Siblings<User, Post, PostUserLikePivot>{
        return siblings(related: Post.self, through: PostUserLikePivot.self)
    }
    
    var dislikedPosts : Siblings<User, Post, PostUserDislikePivot>{
        return siblings(related: Post.self, through: PostUserDislikePivot.self)
    }
    
    var involvedPosts : Siblings<User, Post, PostUserInvolvePivot>{
        return siblings(related: Post.self, through: PostUserInvolvePivot.self)
    }
    
    //For comments
    
    var likedComments : Siblings<User, PostComment, PostCommentUserLikePivot>{
        return siblings(related: PostComment.self, through: PostCommentUserLikePivot.self)
    }
    
    var dislikedComments : Siblings<User, PostComment, PostCommentUserDislikePivot>{
        return siblings(related: PostComment.self, through: PostCommentUserDislikePivot.self)
    }
    
}
