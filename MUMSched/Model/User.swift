//
//  User.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/6/22.
//

import Foundation

enum UserRole: String {
    case ADMIN, FACULTY, STUDENT, ERROR
}

final class User: Codable {
    
    static var current: User?
    
    let id: Int
    let name: String
    let email: String
    private let userRole: String
    
    var role: UserRole {
        return UserRole(rawValue: userRole) ?? .ERROR
    }
}
