import Foundation
import Combine
import SwiftUI

@MainActor
final class DashboardStore: ObservableObject {
    @Published var state: DashboardState
    @Published var persistenceMessage: String?

    let themes: [DashboardTheme]
    private let persistence: DashboardPersistence

    init(persistence: DashboardPersistence) {
        self.themes = DashboardThemes.all
        self.persistence = persistence

        if let loaded = try? persistence.load() {
            state = loaded
            if !themes.contains(where: { $0.id == state.activeThemeID }) {
                state.activeThemeID = themes[0].id
            }
        } else {
            state = DashboardState(activeThemeID: themes[0].id)
        }
    }

    var activeTheme: DashboardTheme {
        themes.first { $0.id == state.activeThemeID } ?? themes[0]
    }

    func setTheme(_ themeID: String) {
        guard themes.contains(where: { $0.id == themeID }) else { return }
        state.activeThemeID = themeID
        persist()
    }

    func cycleTheme() {
        guard let idx = themes.firstIndex(where: { $0.id == state.activeThemeID }) else { return }
        setTheme(themes[(idx + 1) % themes.count].id)
    }

    private func persist() {
        do {
            try persistence.save(state)
            persistenceMessage = nil
        } catch {
            persistenceMessage = error.localizedDescription
        }
    }
}
