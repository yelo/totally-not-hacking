import Foundation
import SwiftUI
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

    @Test func storeCycleThemeWrapsAround() throws {
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("json")
        let store = DashboardStore(persistence: DashboardPersistence(fileURL: url))
        #expect(store.activeTheme.id == DashboardThemes.classicGreen.id)
        store.cycleTheme()
        #expect(store.activeTheme.id == DashboardThemes.amberCRT.id)
        for _ in 0..<5 {
            store.cycleTheme()
        }
        #expect(store.activeTheme.id == DashboardThemes.classicGreen.id)
    }

    @Test func storePersistenceRoundTrips() throws {
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("json")
        let store = DashboardStore(persistence: DashboardPersistence(fileURL: url))
        store.setTheme(DashboardThemes.redAlert.id)
        #expect(store.activeTheme.id == DashboardThemes.redAlert.id)

        let loaded = DashboardStore(persistence: DashboardPersistence(fileURL: url))
        #expect(loaded.activeTheme.id == DashboardThemes.redAlert.id)
    }

    @Test func storeFallsBackWhenSavedThemeMissing() throws {
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("json")
        let store = DashboardStore(persistence: DashboardPersistence(fileURL: url))
        store.setTheme(DashboardThemes.redAlert.id)
        #expect(store.activeTheme.id == DashboardThemes.redAlert.id)

        let state = DashboardState(activeThemeID: "nonexistent-theme-id")
        let data = try JSONEncoder().encode(state)
        try data.write(to: url)

        let loaded = DashboardStore(persistence: DashboardPersistence(fileURL: url))
        #expect(loaded.activeTheme.id == DashboardThemes.classicGreen.id)
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

    // MARK: - Data Generators

    @Test func fmt2FormatsWithTwoDecimals() {
        #expect(fmt2(1.234) == "1.23")
        #expect(fmt2(0.0) == "0.00")
        #expect(fmt2(0.999) == "1.00")
        #expect(fmt2(0.095) == "0.10")
    }

    @Test func pad2ZeroPadsSingleDigit() {
        #expect(pad2(5) == "05")
        #expect(pad2(12) == "12")
        #expect(pad2(0) == "00")
    }

    @Test func hexNibbleProducesUppercaseHex() {
        #expect(hexNibble(0) == "0")
        #expect(hexNibble(10) == "A")
        #expect(hexNibble(15) == "F")
    }

    @Test func pad4HexProducesFourDigitHex() {
        #expect(pad4Hex(0x0000) == "0000")
        #expect(pad4Hex(0x00FF) == "00FF")
        #expect(pad4Hex(0xABCD) == "ABCD")
    }

    @Test func simulatedLoadAveragesAreWithinRange() {
        let (one, five, fifteen) = simulatedLoadAverages(phase: 100.0)
        #expect(one >= 0.1 && one <= 2.0)
        #expect(five >= 0.1 && five <= 1.5)
        #expect(fifteen >= 0.1 && fifteen <= 1.3)
    }

    @Test func breachTracksProducesCorrectCount() {
        let tracks = breachTracks(phase: 100.0, count: 7)
        #expect(tracks.count == 7)
        for track in tracks {
            #expect(track.progress >= 0.05 && track.progress <= 1.0)
            #expect(!track.label.isEmpty)
        }
    }

    @Test func chatterLinesProducesCorrectCount() {
        let lines = chatterLines(phase: 100.0)
        #expect(lines.count == 12)
        for line in lines {
            #expect(line.contains("["))
            #expect(line.contains("@SECTOR-"))
        }
    }

    @Test func codeLineProducesValidSyntax() {
        let line = codeLine(index: 0, phase: 5)
        #expect(line.contains("func "))
        #expect(line.contains("async throws"))

        let indentLine = codeLine(index: 2, phase: 5)
        #expect(indentLine.contains("guard "))
    }

    @Test func lineColorMapsIndexToThemeColors() {
        let theme = DashboardThemes.classicGreen
        #expect(lineColor(index: 0, theme: theme) == theme.accent)
        #expect(lineColor(index: 1, theme: theme) == theme.secondary)
        let defaultColor = lineColor(index: 5, theme: theme)
        #expect(defaultColor == theme.primary.opacity(0.85))
    }

    // MARK: - Fire Simulation

    @Test func fireFieldProducesCorrectDimensions() {
        let field = fireField(cols: 10, rows: 8, phase: 100.0)
        #expect(field.count == 80)
    }

    @Test func fireFieldValuesAreWithinRange() {
        let field = fireField(cols: 10, rows: 8, phase: 100.0)
        for value in field {
            #expect(value >= 0.0 && value <= 1.0)
        }
    }

    @Test func fireFieldBottomRowHasFire() {
        let cols = 10
        let field = fireField(cols: cols, rows: 8, phase: 100.0)
        let lastRowStart = 7 * cols
        for c in 0..<cols {
            #expect(field[lastRowStart + c] >= 0.1)
        }
    }

    @Test func fireFieldTopRowCoolsDown() {
        let cols = 10
        let field = fireField(cols: cols, rows: 8, phase: 100.0)
        for c in 0..<cols {
            #expect(field[c] <= 0.6)
        }
    }

    @Test func doomDecayIsAlwaysPositive() {
        let decay = doomDecay(row: 5, col: 3, phase: 100.0)
        #expect(decay >= 0.0 && decay <= 1.0)
    }

    @Test func fireBandBucketsCorrectly() {
        #expect(fireBand(0.95) == 6)
        #expect(fireBand(0.80) == 5)
        #expect(fireBand(0.60) == 4)
        #expect(fireBand(0.40) == 3)
        #expect(fireBand(0.25) == 2)
        #expect(fireBand(0.10) == 1)
        #expect(fireBand(0.01) == 0)
    }

    @Test func fireBandColorHotBandsUseThemeAccent() {
        let theme = DashboardThemes.classicGreen
        let color6 = fireBandColor(6, intensity: 1.0, theme: theme)
        #expect(color6 != .white)
    }
}
