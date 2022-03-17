//
//  API.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/6/22.
//

import Foundation

public typealias JSON = [String : Any]

public enum API<T: Codable> {
    case login
    case listCourses
    case addCourse
    case updateCourse(id: Int)
    case deleteCourse(id: Int)
    case listBlocks
    case addBlock
    case updateBlock(id: Int)
    case deleteBlock(id: Int)
    case listUsers
    case facultyCourses
    case saveFacultyCourses
}

public struct MUMError: Codable, Error, LocalizedError {
    
    public static var unknown: MUMError {
        return MUMError(status: -1, error: "Unknown", message: "Unknown")
    }
    
    public let status: Int
    public let error: String
    public let message: String
    
    public var errorDescription: String? {
        return message
    }
}

struct EmptyResult: Codable { }
