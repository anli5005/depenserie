//
//  ContentView.swift
//  Depenserie
//
//  Created by Anthony Li on 2/9/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(Register.self) var register
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(register[Account.self]) { account in
                    Text(account.name)
                }
            }
            .navigationTitle("Accounts")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Add", systemImage: "plus") {
                        let id = UUID()
                        register.upsert(record: Account(id: id, name: "Account \(id.uuidString)"))
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
