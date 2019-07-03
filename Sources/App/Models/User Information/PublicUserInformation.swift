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
    
    //Distance, specifically, from the user who is requesting this information.
    let distance : Double
    
    let bio = "This is development quality software. More information will be available at a later time."

    init(fromUserInfo userInfo: UserInformation, distance: Double){
        self.name = userInfo.name
        self.distance = distance
    }
    
    
    
}
