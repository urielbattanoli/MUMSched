//
//  User.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/6/22.
//

import Foundation

enum UserRole: Int {
    case ADMIN = 1
    case FACULTY = 2
    case STUDENT = 3
    case ERROR = -1
}

final class User: Codable {
    
    static var current: User?
    
    let Authorization: String
    let Username: String
    let Userid: String
    private let Roles: String
    
    var id: Int {
        return Int(Userid) ?? -1
    }
    
    var role: UserRole {
        let role = Roles.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
        return UserRole(rawValue: Int(role) ?? -1) ?? .ERROR
    }
}
