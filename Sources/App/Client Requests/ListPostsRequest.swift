//
//  ListPostsRequest.swift
//  App
//
//  Created by Zaccari Silverman on 9/11/19.
//

import Vapor


//A request sent to the server to ask for some number of posts.
struct ListPostsRequest : Content, Validatable {
    let count : Int //The desired number of posts.
    let startIndex : Int //In descending order, start the list with the n-th newest post (zero-indexed).
    
    let userID : User.ID? //If we're looking for the posts of a specific user, we can specify their id here.
    
    //We kind of just want to make sure you can't request 2 million posts and drown the server; we'll set an upper cap of 500 per request or something like that.
    static func validations() throws -> Validations<ListPostsRequest> {
        var validations = Validations(ListPostsRequest.self)
        
        validations.add(\.count, at: ["count"], .range(0...500)) //Make sure the the number requested is less than or equal to 500.
        validations.add(\.startIndex, at: ["startIndex"], .range(0...)) //Make sure the startIndex is more than 0.
        
        return validations
    }
    
}
