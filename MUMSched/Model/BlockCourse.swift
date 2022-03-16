//
//  BlockCourse.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/16/22.
//

import Foundation

final class BlockCourse: Codable, Equatable {
    static func == (lhs: BlockCourse, rhs: BlockCourse) -> Bool { lhs.id == rhs.id }
    
    let id: Int
    let course: Course
    let capacity: Int
    let faculty: String
}
