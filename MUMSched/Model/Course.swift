//
//  Course.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/6/22.
//

import Foundation

final class Course: Codable, Equatable {
    static func == (lhs: Course, rhs: Course) -> Bool { lhs.id == rhs.id }
    
    let id: Int
    let code: String
    let name: String
    let description: String
    let preRequisites: [String]
}
