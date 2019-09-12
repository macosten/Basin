//
//  CreateUserRequest.swift
//  App
//
//  Created by Zaccari Silverman on 9/11/19.
//

import Vapor

/// Data required to create a user.
struct CreateUserRequest: Content, Validatable {
    /// User's full name.
    let name: String
    
    /// User's email address.
    let email: String
    
    /// User's desired password.
    let password: String
    
    /// User's password repeated to ensure they typed it correctly.
    let verifyPassword: String
    
    static func validations() throws -> Validations<CreateUserRequest> {
        var validations = Validations(CreateUserRequest.self)
        validations.add(\.email, at: ["email"], .email) //Email should be at least in some sort of email format.
        
        var nameCharSet = CharacterSet.letters
        nameCharSet.insert(" ")
        validations.add(\.name, at: ["name"], .characterSet(nameCharSet)) //Name should be contain letters and spaces only.
        
        validations.add(\.password, at: ["password"], .count(8...512)) //Don't make password longer than 512 or shorter than 8.
        
        validations.add("Password and password verification must match") { createUserRequest in //A complex validation:
            guard createUserRequest.password == createUserRequest.verifyPassword else {
                throw Abort(.badRequest, reason: "Password and password verification must match.")
            }
        }
        return validations
    }
}

