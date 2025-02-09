//
//  FileRegisterDataSource.swift
//  Depenserie
//
//  Created by Anthony Li on 2/9/25.
//

import Foundation

enum FileRegisterError: Error {
    case unknownRecordType(String)
}

class FileRegisterDataSource: RegisterDataSource {
    let url: URL
    var queuedWrite: Task<Void, Error>?
    
    init(url: URL) {
        self.url = url
    }
    
    func readRecords() throws -> [any Record] {
        if !FileManager.default.fileExists(atPath: url.path(percentEncoded: false)) {
            return []
        }
        
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        struct ProtoRecord: Decodable {
            var type: String
        }
        
        return try data.split(separator: "\n".utf8.first!).compactMap {
            if data.isEmpty { return nil }
            
            let type = try decoder.decode(ProtoRecord.self, from: $0).type
            
            guard let R = allRecordTypes.first(where: { $0.decodesType(type) }) else {
                throw FileRegisterError.unknownRecordType(type)
            }
            
            return try JSONDecoder().decode(R.self, from: $0)
        }
    }
    
    func saveRecords(_ records: any Sequence<any Record>, immediately: Bool) {
        if let queuedWrite {
            queuedWrite.cancel()
        }
        
        queuedWrite = Task {
            if !immediately {
                try await Task.sleep(for: .milliseconds(200))
                try Task.checkCancellation()
            }
            
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.keyEncodingStrategy = .convertToSnakeCase
            
            var data = Data()
            var didWriteFirstRecord = false
            for record in records {
                if didWriteFirstRecord {
                    data.append("\n".utf8.first!)
                } else {
                    didWriteFirstRecord = true
                }
                
                let recordData = try encoder.encode(record)
                data.append(recordData)
            }
            
            try data.write(to: url, options: .atomic)
        }
    }
}
