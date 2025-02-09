//
//  DepenserieApp.swift
//  Depenserie
//
//  Created by Anthony Li on 2/9/25.
//

import SwiftUI

@main
struct DepenserieApp: App {
    @State var register = try! Register(dataSource: FileRegisterDataSource(url: {
        let documentUrl = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        return documentUrl.appendingPathComponent("data.jsonl")
    }()))
    
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(register)
        }
        .onChange(of: scenePhase) {
            if scenePhase == .background {
                print("Entering background, flushing")
                register.flush()
            }
        }
    }
}
