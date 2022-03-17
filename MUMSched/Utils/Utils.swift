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
    
    static func formatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    static func formatDate(date: Date?) -> String? {
        guard let date = date else { return nil }
        return formatter().string(from: date)
    }
}

extension Encodable {
    
    public func toDictionary() -> [String: Any] {
        do {
            let data = try JSONEncoder().encode(self)
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            return json as? [String: Any] ?? [:]
        } catch (let error) {
            print(Self.self)
            print(error)
        }
        return [:]
    }
}
