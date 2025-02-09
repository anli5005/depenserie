//
//  Register.swift
//  Depenserie
//
//  Created by Anthony Li on 2/9/25.
//

import SwiftUI
import IdentifiedCollections

protocol RegisterDataSource {
    func readRecords() throws -> [any Record]
    func saveRecords(_ records: any Sequence<any Record>, immediately: Bool)
}

class MockRegisterDataSource: RegisterDataSource {
    var records: [any Record]
    
    init(records: [any Record] = []) {
        self.records = records
    }
    
    func readRecords() -> [any Record] {
        records
    }
    
    func saveRecords(_ records: any Sequence<any Record>, immediately: Bool) {
        self.records = Array(records)
    }
}

extension RegisterDataSource where Self == MockRegisterDataSource {
    static func mock(records: [any Record]) -> Self {
        MockRegisterDataSource(records: records)
    }
}

@Observable class Register {
    private let dataSource: any RegisterDataSource
    private(set) var records: IdentifiedArray<UUID, any Record>
    private var possiblyDirty = false
    
    init(dataSource: any RegisterDataSource) throws {
        self.dataSource = dataSource
        self.records = try IdentifiedArray(dataSource.readRecords(), id: \.id, uniquingIDsWith: { $1 })
    }
    
    convenience init(mockRecords: [any Record]) {
        try! self.init(dataSource: .mock(records: mockRecords))
    }
    
    subscript<T: Record>(_ type: T.Type) -> [T] {
        records.compactMap { $0 as? T }
    }
    
    subscript<T: Record>(_ type: T.Type, id: UUID) -> T? {
        records[id: id] as? T
    }
    
    func upsert<T: Record>(record: T) {
        let id = record.id
        assert(records[id: id] == nil || records[id: id] is T, "Attempt to set an existing record to a different type")
        records[id: id] = record
        possiblyDirty = true
        dataSource.saveRecords(records, immediately: false)
    }
    
    func remove(id: UUID) -> Bool {
        let result = records.remove(id: id) != nil
        possiblyDirty = true
        dataSource.saveRecords(records, immediately: false)
        
        return result
    }
    
    func flush() {
        if possiblyDirty {
            dataSource.saveRecords(records, immediately: true)
        }
    }
}
