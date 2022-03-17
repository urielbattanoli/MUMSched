//
//  Faculty.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/16/22.
//

import Foundation

final class Faculty: Codable, Equatable {
    static func == (lhs: Faculty, rhs: Faculty) -> Bool { lhs.id == rhs.id }
    
    let id: Int
    let name: String
}
