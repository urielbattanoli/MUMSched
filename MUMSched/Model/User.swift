//
//  User.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/6/22.
//

import Foundation

enum UserRole: String {
    case ADMIN = "[ROLE_ADMIN]"
    case FACULTY = "[ROLE_FACULTY]"
    case STUDENT = "[ROLE_STUDENT]"
    case ERROR
}

final class User: Codable {
    
    static var current: User?
    
    let Authorization: String
    let Username: String
    private let Roles: String
    
    var role: UserRole {
        return UserRole(rawValue: Roles) ?? .ERROR
    }
}
