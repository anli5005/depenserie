//
//  Record.swift
//  Depenserie
//
//  Created by Anthony Li on 2/9/25.
//

import Foundation

protocol Record: Identifiable<UUID>, Codable {
    var id: UUID { get }
    var type: String { get }
    
    static func decodesType(_ type: String) -> Bool
}

let allRecordTypes: [any Record.Type] = [
    Account.self
]

struct Account: Record {
    static let typeName = "account"
    
    var id: UUID
    let type = Self.typeName
    var name: String
    
    enum CodingKeys: CodingKey {
        case id
        case type
        case name
    }
    
    static func decodesType(_ type: String) -> Bool {
        type == Self.typeName
    }
}
