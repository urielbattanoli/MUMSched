//
//  Block.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/16/22.
//

import Foundation

final class Block: Codable, Equatable {
    static func == (lhs: Block, rhs: Block) -> Bool { lhs.id == rhs.id }
    
    let id: Int
    private let startDate: String
    let blockCourses: [BlockCourse]?
    
    var start: Date {
        return Utils.formatter().date(from: startDate) ?? Date()
    }
}
