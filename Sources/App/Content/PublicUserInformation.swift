//
//  PublicUserInformation.swift
//  App
//
//  Created by Zaccari Silverman on 7/1/19.
//

import Vapor

struct PublicUserInformation : Content {
    
    //Name of the user whose UserInfo this object was derived from.
    let name : String
    
    init(fromUserInfo userInfo: UserInformation){
        name = userInfo.name
    }
    
    
    
}
