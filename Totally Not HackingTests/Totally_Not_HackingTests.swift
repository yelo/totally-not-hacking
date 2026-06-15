//
//  Totally_Not_HackingTests.swift
//  Totally Not HackingTests
//
//  Created by Jimmy Kumpulainen on 2026-06-15.
//

import Foundation
import Testing
@testable import Totally_Not_Hacking

@MainActor
struct Totally_Not_HackingTests {

    @Test func registryRegistersAllInitialWidgets() {
        let registry = WidgetRegistry()
        DefaultWidgetCatalog.registerAll(into: registry)

        #expect(registry.descriptors.count == 10)
        #expect(registry.contains("matrix-rain"))
        #expect(registry.contains("fake-satellite-tracker"))
    }

    @Test func dashboardStateRoundTrips() throws {
        let original = DashboardState(
            layoutMode: .hybrid,
            activeThemeID: DashboardThemes.iceBlue.id,
            selectedWidgetIDs: [UUID(uuidString: "11111111-1111-1111-1111-111111111111")!],
            widgets: [
                DashboardWidgetInstance(
                    widgetID: "terminal-stream",
                    placement: WidgetPlacement(x: 0.1, y: 0.2, width: 0.3, height: 0.2, zIndex: 1),
                    presentationMode: .floating,
                    isSelected: true,
                    isVisible: true,
                    configurationData: Data()
                )
            ]
        )

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(DashboardState.self, from: data)

        #expect(decoded == original)
    }

    @Test func storeBootstrapsFullWidgetSet() throws {
        let registry = WidgetRegistry()
        DefaultWidgetCatalog.registerAll(into: registry)

        let persistenceURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString).appendingPathExtension("json")
        let store = DashboardStore(
            registry: registry,
            persistence: DashboardPersistence(fileURL: persistenceURL)
        )

        #expect(store.state.widgets.count == 10)
        #expect(store.state.layoutMode == .hybrid)
        #expect(store.activeTheme.id == DashboardThemes.classicGreen.id)
    }

    @Test func asciiHelpersProduceExpectedShapes() {
        #expect(asciiBar(level: 0.5, width: 6) == "[###---]")
        #expect(asciiMeter(level: 0.5, width: 5) == "..>..")
        #expect(matrixGlyph(at: 0, phase: 0).count == 1)
        #expect(["ア", "カ", "サ", "タ", "ナ", "ハ", "マ", "ヤ", "ラ", "ワ", "ン"].contains(matrixGlyph(at: 0, phase: 0)))
    }

}
