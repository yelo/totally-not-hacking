//
//  Totally_Not_HackingApp.swift
//  Totally Not Hacking
//
//  Created by Jimmy Kumpulainen on 2026-06-15.
//

import SwiftUI

@main
struct Totally_Not_HackingApp: App {
    @StateObject private var store: DashboardStore

    init() {
        let registry = WidgetRegistry()
        DefaultWidgetCatalog.registerAll(into: registry)

        do {
            let persistence = try DashboardPersistence.live()
            _store = StateObject(wrappedValue: DashboardStore(registry: registry, persistence: persistence))
        } catch {
            fatalError("Could not create dashboard persistence: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environmentObject(store)
    }
}
