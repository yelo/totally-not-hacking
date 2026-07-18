# Assumptions

These are hypotheses about the codebase that should be verified before acting on them.

### Architecture

- [ ] A `DashboardWidget` protocol exists that widgets conform to
- [ ] A `WidgetRegistry` type exists for registering widgets
- [ ] A `DefaultWidgetCatalog` exists and is called from the app entry point
- [ ] Widgets live in per-widget subdirectories under `Widgets/`
- [ ] The dashboard shell uses `NavigationSplitView` with sidebar/detail
- [ ] The layout system supports tiled, floating, and hybrid modes
- [ ] `WidgetPlacement` with fractional coordinate system is implemented
- [ ] `WidgetChromeView` with title bar and glow borders exists
- [ ] Drag-to-move and resize handle are implemented for widgets

### Implemented Widgets

- [ ] 10 built-in widgets are registered (`TerminalStreamWidget`, `MatrixRainWidget`, `FakeNetworkMonitorWidget`, `WorldActivityMapWidget`, `RadarScreenWidget`, `CPUUsageSimulatorWidget`, `LogViewerWidget`, `HexDumpViewerWidget`, `ScrollingErrorConsoleWidget`, `FakeSatelliteTrackerWidget`)
- [ ] Each widget has its own `Configuration` type conforming to `Codable & Hashable`
- [ ] Each widget implements `makeView(configuration:context:)`

### Testing

- [ ] Tests assert the expected widget count from `DefaultWidgetCatalog`
- [ ] `FloatingWidgetConnectorOverlay` with animated canvas lines exists

### Persistence

- [ ] `DashboardState` includes layoutMode, activeThemeID, selectedWidgetIDs, and widgets array
- [ ] `DashboardStore.bootstrapState()` assigns some widgets as `.background` and others as `.floating`
- [ ] `DashboardStore.mergedState()` reconciles persisted state with registry
