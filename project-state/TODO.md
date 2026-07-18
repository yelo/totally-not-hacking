# TODO

## High Priority

- [ ] Implement `DashboardWidget` protocol with associated `Configuration: Codable & Hashable`
- [ ] Implement `WidgetRegistry` (`@MainActor` type-erased registry)
- [ ] Implement `DefaultWidgetCatalog.registerAll(into:)` with all 10 widgets
- [ ] Create widget subdirectories and split `WidgetSupport.swift` helpers

## Medium Priority

- [ ] Implement `WidgetPlacement` with fractional coordinate system, clamped/snapped
- [ ] Build `NavigationSplitView`-based shell with DashboardControlPanel + DashboardCanvasView
- [ ] Implement tiled / floating / hybrid layout modes
- [ ] Build `WidgetChromeView` with title bar, icon, action buttons, glow shadow
- [ ] Implement drag-to-move and resize handle on foreground widgets
- [ ] Add `FloatingWidgetConnectorOverlay` with animated canvas lines
- [ ] Create `WidgetSettingsSheet` for per-widget configuration

## Widgets to Implement

- [ ] `TerminalStreamWidget`
- [ ] `FakeNetworkMonitorWidget`
- [ ] `WorldActivityMapWidget`
- [ ] `RadarScreenWidget`
- [ ] `CPUUsageSimulatorWidget`
- [ ] `LogViewerWidget`
- [ ] `HexDumpViewerWidget`
- [ ] `ScrollingErrorConsoleWidget`
- [ ] `FakeSatelliteTrackerWidget`

## Testing

- [ ] Add tests for new protocol/registry/catalog
- [ ] Add test for expected widget count (10)
- [ ] Test layout mode persistence round-trip

## Polish

- [ ] Wire up all 6 themes properly
- [ ] Performance: background widgets should use `.drawingGroup()`
- [ ] Verify all animations use `TimelineView(.animation(...))` — no timers
