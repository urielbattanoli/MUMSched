//
//  API+Configuration.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/6/22.
//

import Foundation

extension API {
    
    static var baseURL: URL! {
        return URL(string: "https://mumsched-backend.herokuapp.com/api")
    }
}
