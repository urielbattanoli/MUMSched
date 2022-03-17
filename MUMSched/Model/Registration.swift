//
//  Registration.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/17/22.
//

import Foundation

final class Registration: Codable {
    
    let blocks: [BlockRegistration]
}

final class BlockRegistration: Codable {
    
    let blockId: Int
    var coursePriorities: [CoursePriority]
}

final class CoursePriority: Codable {
    
    var priority: Int
    let blockCourse: BlockCourse
}
