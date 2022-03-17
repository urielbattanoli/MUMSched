//
//  API+Request.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/6/22.
//

import Foundation
import Alamofire

extension API {
    
    var url: URL {
        switch self {
        default:
            return API.baseURL.appendingPathComponent(path)
        }
    }
    
    var path: String {
        switch self {
        case .login: return "login"
        case .listCourses, .addCourse: return "courses"
        case .updateCourse(let id), .deleteCourse(let id): return "courses/\(id)"
        case .listBlocks, .addBlock: return "blocks"
        case .updateBlock(let id), .deleteBlock(let id): return "blocks/\(id)"
        case .listUsers: return "users"
        case .facultyCourses: return "users/faculty/courses"
        case .saveFacultyCourses: return "users/faculty/courses"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .listCourses, .listBlocks, .listUsers, .facultyCourses: return .get
        case .deleteCourse, .deleteBlock: return .delete
        case .updateCourse, .updateBlock, .saveFacultyCourses: return .put
        default: return .post
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        case .listUsers: return URLEncoding.default
        default: return JSONEncoding.default
        }
    }
    
    var headers: HTTPHeaders {
        var headers: HTTPHeaders = [:]
        if let token = User.current?.Authorization {
            headers["Authorization"] = token
        }
        return headers
    }
}
