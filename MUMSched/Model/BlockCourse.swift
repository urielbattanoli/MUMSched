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
    let availableSeats: Int
    let faculty: Faculty
}

final class BlockCourseCreation: Codable {
    
    let courseId: Int
    let availableSeats: Int
    let facultyId: Int
    let blockId: Int
    
    init(courseId: Int, capacity: Int, facultyId: Int, blockId: Int) {
        self.courseId = courseId
        self.availableSeats = capacity
        self.facultyId = facultyId
        self.blockId = blockId
    }
}
