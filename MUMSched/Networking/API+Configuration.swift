//
//  API+Configuration.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/6/22.
//

import Foundation

extension API {
    
    static var baseURL: URL! {
        return URL(string: "https://www.api.flockr.social/parse")
    }
    
    static var headerApplicationId: String {
        return "daa86939e800c434d3d0a68825a529bb" // X-Parse-Application-Id
    }
    
    static var headerRestAPIKey: String {
        return "771313f83b9d6c0e60ad33a2b549cab5" // X-Parse-REST-API-Key
    }
    
}
