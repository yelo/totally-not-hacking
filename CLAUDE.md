# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

- Open `Totally Not Hacking.xcodeproj` in Xcode 16+
- Run the `Totally Not Hacking` scheme on an iPadOS simulator or device
- No CLI build tools, Package.swift, or Makefile — this is Xcode-only
- Tests use the **Swift Testing** framework (`@Test` macro, `#expect`). Run with ⌘U in Xcode. No XCTest.

## Architecture

The app is an iPadOS SwiftUI dashboard that simulates fictional movie-style hacker interfaces. All data is purely simulated; nothing performs real networking, scanning, or intrusion.

### App Entry Point

`Totally_Not_HackingApp.swift` — `@main` struct creates the object graph at launch:
1. Creates a `WidgetRegistry`
2. Calls `DefaultWidgetCatalog.registerAll(into:)` to register all 10 built-in widgets
3. Creates `DashboardPersistence.live()` (JSON file in `ApplicationSupport/TotallyNotHacking/dashboard-state.json`)
4. Creates a `DashboardStore` (the central `@MainActor ObservableObject`), attempting to load persisted state first, falling back to `bootstrapState()`
5. Injects it via `.environmentObject(store)` into `ContentView`

### Core Layer (`Core/`)

- **`DashboardModels.swift`** — All shared types:
  - `DashboardLayoutMode` enum: `.tiled`, `.floating`, `.hybrid`
  - `WidgetCategory` enum: terminal, telemetry, maps, diagnostics, logs, background
  - `WidgetPresentationMode` enum: `.tiled`, `.floating`, `.background`
  - `WidgetFractionalSize`: width/height pair with presets `.standard` (0.28×0.22), `.wide` (0.38×0.20), `.tall` (0.24×0.30), `.background` (1×1)
  - `WidgetMetadata`: id, name, description, category, iconSystemName, defaultSize, supportedPresentationModes
  - `WidgetPlacement`: fractional coordinate system (0–1) with x, y, width, height, zIndex. Includes `clamped()`, `snapped(to:rows:)`, `rect(in:)`, and `defaultPlacement(index:size:presentationMode:)` helpers
  - `DashboardWidgetInstance`: a placed widget with UUID, widgetID, placement, presentationMode, configurationData (opaque `Data` blob)
  - `DashboardState`: layoutMode, activeThemeID, selectedWidgetIDs, widgets array
  - `WidgetContext`: theme + layoutMode + containerSize, passed to widget views
  - `DashboardWidget` protocol: associated-type `Configuration: Codable & Hashable`, requires `static var metadata`, `static var defaultConfiguration`, `static func makeView(configuration:context:) -> AnyView`, and optionally `makeSettingsView(configuration:) -> AnyView`

- **`WidgetRegistry.swift`** — `@MainActor` type-erased registry. Widgets are registered via `registry.register(MyWidget.self)`. Internally wraps each widget as an `AnyWidgetDescriptor` that stores metadata, default config as `Data`, and closures for `makeView` / `makeSettingsView`. The closures handle Codable encode/decode bridging via `JSONEncoder`/`JSONDecoder`, falling back to `defaultConfiguration` on decode failure.

- **`DashboardStore.swift`** — `@MainActor ObservableObject`, the central state manager:
  - On init, attempts `persistence.load()`; falls back to `bootstrapState()` which creates instances for every registered widget
  - `bootstrapState()` assigns `matrix-rain` and `world-activity-map` as `.background`; all others as `.floating`. Default layout mode is `.hybrid`.
  - `mergedState()` reconciles persisted state with the registry: adds any newly-registered widgets that aren't in the persisted state
  - Persistence is NOT debounced — `persist()` writes synchronously on every mutation (add, remove, placement update, selection change, etc.)
  - Provides CRUD for widgets, placement updates (snapped in tiled mode, clamped otherwise), selection management, z-index ordering, duplicate, and layout reset

- **`DashboardTheme.swift`** — `DashboardTheme` with a `Palette` of hex colors + `glowIntensity`. Four built-in themes in `DashboardThemes.all`: classic-green-terminal, amber-crt, ice-blue, red-alert. Includes `Color(hex:)` extension supporting 6-digit and 8-digit hex. Theme also exposes `headlineFont` and `bodyFont` (both monospaced).

- **`DashboardPersistence.swift`** — Thin JSON file persistence with pretty-printed + sorted-keys output. `live()` resolves to `ApplicationSupport/TotallyNotHacking/dashboard-state.json`, creating directories as needed. Read/write throws on I/O errors; `DashboardStore` surfaces errors via `persistenceMessage`.

### UI Layer (`UI/`)

- **`DashboardShellView.swift`** — The entire dashboard rendering and control:
  - `ContentView` reads `@EnvironmentObject` store, delegates to `DashboardShellView`
  - `DashboardShellView` uses `NavigationSplitView`: sidebar is `DashboardControlPanel`, detail is `DashboardCanvasView`
  - `DashboardControlPanel` provides layout mode picker, theme picker, widget library (grouped by category), active widgets list with edit/duplicate/delete
  - `DashboardCanvasView` uses `GeometryReader` to get `containerSize`, then renders a `ZStack`:
    1. Theme background color
    2. `DashboardBackdropGrid` (12×8 or 16×10 Canvas-drawn grid at 4–6% opacity, with a horizontal accent scanline)
    3. Background widgets (`.presentationMode == .background`) via `WidgetBackdropHost` — `.allowsHitTesting(false)`, full-frame
    4. Foreground widgets via `WidgetHostView` — wrapped in `WidgetChromeView` (title bar with icon/name/category + action buttons, rounded rect border with glow shadow), positioned via `.position(x:y:)` using fractional coordinates × container size
    5. `FloatingWidgetConnectorOverlay` — animated Canvas that draws lines between telemetry/maps-category widgets with pulsing edge-anchor nodes. Uses `TimelineView(.animation)` as the driver
  - `WidgetHostView` supports drag-to-move (via `DragGesture` updating placement) and resize handle (bottom-right corner, updates width/height in fractional space)
  - `WidgetSettingsSheet` presents the widget's `makeSettingsView` in a modal sheet with a `Done` button

- **`WidgetChromeHelpers.swift`** — `dashboardPanelStyle(theme:)` View extension for panel chrome (used by some widgets for consistent inner styling)

### Widget System (`Widgets/`)

Each widget is a struct conforming to `DashboardWidget` with a private view struct:

```swift
struct MyWidget: DashboardWidget {
    struct Configuration: Codable, Hashable { ... }
    static let metadata = WidgetMetadata(...)
    static let defaultConfiguration = Configuration()
    static func makeView(configuration: Configuration, context: WidgetContext) -> AnyView {
        AnyView(MyWidgetView(configuration: configuration, theme: context.theme))
    }
}
private struct MyWidgetView: View { ... }
```

**Performance conventions for widget rendering:**
- Continuous animations use `TimelineView(.animation(minimumInterval:paused:))` with the timeline date as the animation driver (no timers)
- Custom drawing uses `Canvas` with `context.fill(Path, with:)` and `context.draw(Text, at:)`
- Background widgets use `.drawingGroup()` to flatten into a single layer
- Helper functions in `WidgetSupport.swift` generate deterministic pseudo-random data: `waveformValues(count:phase:seed:amplitude:)`, `simulatedLogLine(prefix:index:phase:)`, `hexStream(seed:rows:columns:phase:)`, `glyphStream(for:)`, `asciiBar(level:width:filled:empty:)`, `asciiMeter(level:width:head:)`, `matrixGlyph(at:phase:)`, and the `glowingText(theme:)` View modifier

**Registered widgets** (in `DefaultWidgetCatalog.registerAll`): `TerminalStreamWidget`, `MatrixRainWidget`, `FakeNetworkMonitorWidget`, `WorldActivityMapWidget`, `RadarScreenWidget`, `CPUUsageSimulatorWidget`, `LogViewerWidget`, `HexDumpViewerWidget`, `ScrollingErrorConsoleWidget`, `FakeSatelliteTrackerWidget` — 10 total. The test at `Totally_Not_HackingTests.swift:15` asserts this count.

**Unregistered widget files on disk:** `DoomFireWidget.swift`, `MainframeBreachWidget.swift`, `PseudoCodeStreamWidget.swift` — these are new, untracked files with complete `DashboardWidget` implementations but not yet added to `DefaultWidgetCatalog.registerAll`.

## Coordinate System

All widget placement uses a fractional 0–1 coordinate system that maps to the container size at render time. `WidgetPlacement.rect(in:)` converts to `CGRect`. The `clamped()` method ensures width/height stay in [0.08, 1] and position stays within bounds. `snapped(to:rows:)` aligns to a grid (12×8 or 16×10) for tiled mode.

## Commit & Branch Conventions

- Commit messages: **Conventional Commits** (`feat:`, `fix:`, `perf:`, `chore:`, etc.)
- Branch names: `feat/...`, `fix/...`, `docs/...`, `chore/...`, `ci/...`, `perf/...`

## Key Constraints

- **iPad-only** — not designed for iPhone or Mac
- **No real functionality** — everything is simulated entertainment. Do not add real networking, scanning, intrusion, or credential handling
- **Xcode 16+ required**
- **To add a new widget**: implement `DashboardWidget`, add it to `DefaultWidgetCatalog.registerAll(into:)`, and update the test assertion for the expected widget count
