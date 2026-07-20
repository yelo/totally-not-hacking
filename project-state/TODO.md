# TODO

Updated: 2026-07-18

## Open

| ID | Opened | Task | Area | Priority | Notes |
|---|---|---|---:|---|---|
| T-001 | 2026-07-18 | Implement `DashboardWidget` protocol with associated `Configuration: Codable & Hashable` | core | high | Currently no protocol exists — MatrixRainWidgetView is a standalone struct. Protocol must support `metadata`, `defaultConfiguration`, `makeView(configuration:context:)`, and optional `makeSettingsView`. |
| T-002 | 2026-07-18 | Implement `WidgetRegistry` (`@MainActor` type-erased registry) | core | high | Described in AGENTS.md but not coded. Must wrap each widget as `AnyWidgetDescriptor` with metadata, default config as `Data`, and view/settings closures handling Codable bridging. |
| T-003 | 2026-07-18 | Implement `DefaultWidgetCatalog.registerAll(into:)` with all 10 widgets | core | high | Currently referenced only in AGENTS.md. Must register all 10 built-in widgets. Then update test assertion for widget count. |
| T-004 | 2026-07-18 | Create widget subdirectories per-widget | widgets | high | Currently all widget code is flat in `Widgets/`. Should split into per-widget folders. |
| T-005 | 2026-07-18 | Implement remaining 9 widgets | widgets | high | Only MatrixRainWidget is implemented. Needed: TerminalStreamWidget, FakeNetworkMonitorWidget, WorldActivityMapWidget, RadarScreenWidget, CPUUsageSimulatorWidget, LogViewerWidget, HexDumpViewerWidget, ScrollingErrorConsoleWidget, FakeSatelliteTrackerWidget. |
| T-006 | 2026-07-18 | Implement `WidgetPlacement` with fractional coordinate system | layout | medium | Types (`WidgetPlacement`, `WidgetFractionalSize`, `WidgetMetadata`) described in AGENTS.md. Must support 0–1 coordinates, `clamped()`, `snapped(to:rows:)`, `rect(in:)`. |
| T-007 | 2026-07-18 | Build `NavigationSplitView`-based shell with sidebar and detail | ui | medium | Current shell uses fixed 4-layer ZStack with 3 panes. Replace with `NavigationSplitView` where sidebar is `DashboardControlPanel` and detail is `DashboardCanvasView`. |
| T-008 | 2026-07-18 | Implement tiled/floating/hybrid layout modes | layout | medium | `DashboardLayoutMode` enum described but not implemented. Tiled snaps to grid, floating allows free placement, hybrid layers background + floating widgets. |
| T-009 | 2026-07-18 | Build `WidgetChromeView` with title bar and glow borders | ui | medium | Each foreground widget needs chrome: icon, name, category, action buttons, rounded rect border with glow shadow. |
| T-010 | 2026-07-18 | Implement drag-to-move and resize handle | ui | medium | `WidgetHostView` needs `DragGesture` for repositioning and bottom-right resize handle for width/height adjustment in fractional space. |
| T-011 | 2026-07-18 | Add `FloatingWidgetConnectorOverlay` with animated canvas lines | ui | medium | Animated Canvas drawing lines between telemetry/maps-category widgets with pulsing edge-anchor nodes. Driven by `TimelineView(.animation)`. |
| T-012 | 2026-07-18 | Create `WidgetSettingsSheet` for per-widget configuration | ui | medium | Modal sheet presenting widget's `makeSettingsView` with a `Done` button to dismiss. |
| T-013 | 2026-07-18 | Add tests for new protocol/registry/catalog | testing | medium | Tests for `DashboardWidget` registration, `WidgetRegistry` round-trip encode/decode, `DefaultWidgetCatalog` completeness. |
| T-014 | 2026-07-18 | Add widget count assertion test | testing | medium | Assert `DefaultWidgetCatalog` registers exactly 10 widgets. Update existing test count if needed. |
| T-015 | 2026-07-18 | Test layout mode persistence round-trip | testing | medium | Verify `DashboardState` with `layoutMode`, `widgets` array survives JSON encode/decode. |
| T-016 | 2026-07-18 | Wire up all 6 themes through full rendering pipeline | themes | medium | 6 themes exist in `DashboardThemes.all` but cycle button only changes `activeThemeID`. Verify all theme tokens (colors, glow, scanline) flow consistently through every view. |
| T-017 | 2026-07-18 | Verify all animations use `TimelineView(.animation(...))` — no timers | perf | medium | MatrixRain uses `TimelineView(.animation(minimumInterval: 0.05))`. Ensure no widget or effect uses `Timer` or `DispatchQueue` for continuous animation. |

## Done

| ID | Task | Completed in | Notes |
|---|---|---|---|
| T-201 | Cache Color values in Palette (precompute once, custom Codable) | 2026-07-20 | Eliminated per-access Scanner allocations during rendering. Colors stored as Palette stored properties, hex strings used only for Codable serialization. |
| T-202 | Replace fireField 2D array with flat [Double] buffer | 2026-07-20 | Single allocation with manual index math. 0 allocations per frame vs 46. |
| T-203 | Add .drawingGroup() to MatrixRain Canvas | 2026-07-20 | Matches pattern used by CRT scanline and backdrop grid. |
| T-204 | Replace String(format:) with interpolation in hot loops | 2026-07-20 | chatterLines, codeLine, statusLines use native interpolation + pad2/pad2Hex helpers. |
| T-205 | Debounce persistence writes (0.3s) | 2026-07-20 | Cancellable Task in DashboardStore replaces synchronous write-on-every-mutation. |
| T-206 | Guard scroll-to-bottom on actual phase change | 2026-07-20 | BottomLeftPane avoids wasted layout passes. |
| T-207 | Remove dead code | 2026-07-20 | Removed waveformValues, simulatedLogLine, hexStream, glyphStream, dashboardPanelStyle. Kept asciiBar/asciiMeter (tested). |
| T-101 | Merge CLAUDE.md into AGENTS.md | 2026-07-18 | Deleted CLAUDE.md. Merged architecture file breakdown, build/run instructions, coordinate system, performance conventions, and key constraints into AGENTS.md. |
| T-102 | Add project-state agent workflow | 2026-07-18 | Created `project-state/` directory with PROJECT_CONTEXT.md, ASSUMPTIONS.md, TODO.md, DECISIONS.md. Replaced AGENTS.md with process-oriented format. |
| T-103 | Trim README.md to install/run/usage only | 2026-07-18 | Removed architecture descriptions, layout modes section, theme listing, widget listing, and non-goals. Kept only requirements, run instructions, and how-to-use guide with 6 themes listed. |
| T-104 | Complete TUI overhaul with fixed 3-pane layout | 2026-07-06 | Replaced prior UI with 4-layer ZStack: MatrixRain background, CRT scanlines, backdrop grid, 3 content panes (top terminal 44%, bottom-left pseudo-code, bottom-right doom fire thermal viz). |
| T-105 | Integrate dashboard theme system with 6 themes | 2026-06-15 | Implemented `DashboardTheme` + `Palette` with 7 hex color tokens, `Color(hex:)` extension (6-digit and 8-digit), 6 built-in themes, and monospaced typography. |
| T-106 | Implement JSON file persistence | 2026-06-15 | `DashboardPersistence` reads/writes `DashboardState` to `ApplicationSupport/TotallyNotHacking/dashboard-state.json` with pretty-printed sorted-key JSON output. |
| T-107 | Implement DashboardStore state manager | 2026-06-15 | `@MainActor ObservableObject` with `@Published state` and `persistenceMessage`. Theme management via `setTheme()` / `cycleTheme()` with synchronous persist. |
| T-108 | Build MatrixRain widget | 2026-06-15 | Full-screen matrix rain animation using `TimelineView(.animation(minimumInterval: 0.05))` and `Canvas` with configurable columns/speed/brightness. |
| T-109 | Add CRT scanline and backdrop grid effects | 2026-06-15 | `CRTScanlineOverlay` (Canvas-drawn 1px lines at 4px spacing, `.drawingGroup()`), `DashboardBackdropGrid` (12×8 Canvas grid with accent scanline). |
| T-110 | Add WidgetSupport helpers | 2026-06-15 | Shared rendering: `waveformValues`, `simulatedLogLine`, `hexStream`, `glyphStream`, `asciiBar`, `asciiMeter`, `tuiBar`, `tuiMeter`, `tuiDivider`, `glowingText`, `crtGlow`. |
| T-111 | Set up Swift Testing framework with 5 tests | 2026-06-15 | Unit tests covering state round-trip, store init with default theme, ASCII shape helpers, TUI shape helpers, and theme count (6). |
| T-112 | Add CI with Release Please | 2026-06-15 | GitHub Actions workflow (`release-please.yml`) running on push to `main`. |
| T-113 | Add htop-style process panel | 2026-06-15 | CPU usage simulator in `TopTerminalPane` with load averages and process listing. |
| T-114 | Refine ASCII dashboard visuals | 2026-06-15 | Visual polish pass across all ASCII-rendered elements. |
| T-115 | Anchor monitor connectors to widget edges | 2026-06-15 | Fixed connector lines between telemetry-style widgets to attach at proper edge anchors. |
| T-116 | Restore cinematic matrix rain effect | 2026-06-15 | Fixed regression in MatrixRain animation timing and glyph rendering. |
