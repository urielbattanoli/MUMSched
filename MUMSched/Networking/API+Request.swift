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
        }
    }
    
    var method: HTTPMethod {
        switch self {
//        case : return .delete
//        case : return .get
//        case : return .put
        default: return .post
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        default: return JSONEncoding.default
        }
    }
    
    var headers: HTTPHeaders {
//        var headers: HTTPHeaders = [
//            "Content-Type": "application/json",
//            "X-Parse-Application-Id": API.headerApplicationId,
//            "X-Parse-REST-API-Key": API.headerRestAPIKey
//        ]
        
//        if let token = User.current?.sessionToken {
//            headers["X-Parse-Session-Token"] = token
//        }
//        if let id = Profile.current?.objectId {
//            headers["selected-profile-id"] = id
//        }
//        if let id = Defaults.shared.installationId {
//            headers["X-Parse-Installation-Id"] = id
//        }
        
        return [:]
    }
}
