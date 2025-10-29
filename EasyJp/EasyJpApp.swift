//
//  EasyJpApp.swift
//  EasyJp
//
//  Created by ividernvi on 2025/10/29.
//

import SwiftUI
import SwiftData

let version = "0.0.0"

@main
struct EasyJpApp: App {
    @StateObject private var wordManager = WordManager()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainpageView()
                .environmentObject(wordManager)
        }
        .modelContainer(sharedModelContainer)
    }
}

