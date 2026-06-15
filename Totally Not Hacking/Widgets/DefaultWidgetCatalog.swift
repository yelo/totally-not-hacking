import Foundation

enum DefaultWidgetCatalog {
    static func registerAll(into registry: WidgetRegistry) {
        registry.register(TerminalStreamWidget.self)
        registry.register(MatrixRainWidget.self)
        registry.register(FakeNetworkMonitorWidget.self)
        registry.register(WorldActivityMapWidget.self)
        registry.register(RadarScreenWidget.self)
        registry.register(CPUUsageSimulatorWidget.self)
        registry.register(LogViewerWidget.self)
        registry.register(HexDumpViewerWidget.self)
        registry.register(ScrollingErrorConsoleWidget.self)
        registry.register(FakeSatelliteTrackerWidget.self)
    }
}

