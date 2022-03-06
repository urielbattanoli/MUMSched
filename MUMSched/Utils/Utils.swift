//
//  Utils.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/6/22.
//

import Foundation

struct Utils {
    
    static func className(for _class: AnyClass) -> String {
        let str = String(describing: type(of: _class))
        guard str.hasSuffix(".Type") else {
            return str
        }
        return String(str[..<str.index(str.endIndex, offsetBy: -5)])
    }
}
