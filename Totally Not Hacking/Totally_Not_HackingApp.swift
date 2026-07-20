import SwiftUI

@main
struct Totally_Not_HackingApp: App {
    @StateObject private var store: DashboardStore

    init() {
        let persistence = (try? DashboardPersistence.live()) ?? DashboardPersistence(
            fileURL: FileManager.default.temporaryDirectory.appendingPathComponent("tnh-fallback.json")
        )
        _store = StateObject(wrappedValue: DashboardStore(persistence: persistence))
    }

    var body: some Scene {
        WindowGroup {
            DashboardShellView()
                .environmentObject(store)
        }
    }
}
