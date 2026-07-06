import Foundation
import Testing
@testable import Totally_Not_Hacking

@MainActor
struct Totally_Not_HackingTests {

    @Test func dashboardStateRoundTrips() throws {
        let original = DashboardState(activeThemeID: DashboardThemes.iceBlue.id)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(DashboardState.self, from: data)
        #expect(decoded == original)
        #expect(decoded.activeThemeID == DashboardThemes.iceBlue.id)
    }

    @Test func storeInitializesWithDefaultTheme() throws {
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("json")
        let store = DashboardStore(persistence: DashboardPersistence(fileURL: url))
        #expect(store.activeTheme.id == DashboardThemes.classicGreen.id)
        #expect(store.themes.count == 6)
    }

    @Test func asciiHelpersProduceExpectedShapes() {
        #expect(asciiBar(level: 0.5, width: 6) == "[###---]")
        #expect(asciiMeter(level: 0.5, width: 5) == "..>..")
        #expect(matrixGlyph(at: 0, phase: 0).count == 1)
        #expect(["ア", "カ", "サ", "タ", "ナ", "ハ", "マ", "ヤ", "ラ", "ワ", "ン"].contains(matrixGlyph(at: 0, phase: 0)))
    }

    @Test func tuiHelpersProduceExpectedShapes() {
        #expect(tuiBar(level: 1.0, width: 4) == "████")
        #expect(tuiBar(level: 0.0, width: 4) == "░░░░")
        #expect(tuiBar(level: 0.5, width: 6).count == 6)
        #expect(tuiMeter(level: 0.5, width: 5).count == 5)
        #expect(tuiMeter(level: 0.0, width: 3).contains("◆"))
        #expect(tuiMeter(level: 1.0, width: 3).contains("◆"))
        #expect(tuiDivider(length: 4) == "════")
        #expect(tuiDivider(length: 3, char: "─") == "───")
    }

    @Test func themeCountIsSix() {
        #expect(DashboardThemes.all.count == 6)
    }
}
