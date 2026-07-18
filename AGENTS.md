# AGENTS.md

## Project

Totally Not Hacking — An iPadOS SwiftUI dashboard application that simulates fictional movie-style hacker interfaces. All data is purely simulated; nothing performs real networking, scanning, or intrusion.

No functionality should perform real hacking, security testing, packet inspection, intrusion, vulnerability scanning, credential handling, or unauthorized access.

The application is a visual simulator only.

---

# Guiding Principles

1. Widget platform first.
2. Visual effects second.
3. Features should be implemented as widgets whenever possible.
4. New widgets should require minimal framework changes.
5. Composition is preferred over inheritance.
6. Maintainability is preferred over cleverness.

---

# Architecture

## Primary Layers

### Core

Contains:

* Widget framework
* Theme framework
* Layout framework
* Persistence
* Shared protocols

Core must not depend on individual widgets.

### Widgets

Each widget lives in its own folder.

Example:

Widgets/
TerminalStream/
MatrixRain/
RadarScreen/

Widgets should only depend on Core.

### Features

Cross-widget functionality.

Examples:

* Theme management
* Dashboard editing
* Widget browser
* Import/export layouts

### App

Application entry point.

## App Entry Point

`Totally_Not_HackingApp.swift` — `@main` struct creates the object graph at launch:
1. Creates a `WidgetRegistry`
2. Calls `DefaultWidgetCatalog.registerAll(into:)` to register all built-in widgets
3. Creates `DashboardPersistence.live()` (JSON file in `ApplicationSupport/TotallyNotHacking/dashboard-state.json`)
4. Creates a `DashboardStore` (the central `@MainActor ObservableObject`), attempting to load persisted state first, falling back to `bootstrapState()`
5. Injects it via `.environmentObject(store)` into `ContentView`

## Core Layer Details

### DashboardModels.swift

All shared types:
- `DashboardLayoutMode` enum: `.tiled`, `.floating`, `.hybrid`
- `WidgetCategory` enum: terminal, telemetry, maps, diagnostics, logs, background
- `WidgetPresentationMode` enum: `.tiled`, `.floating`, `.background`
- `WidgetFractionalSize`: width/height pair with presets `.standard` (0.28×0.22), `.wide` (0.38×0.20), `.tall` (0.24×0.30), `.background` (1×1)
- `WidgetMetadata`: id, name, description, category, iconSystemName, defaultSize, supportedPresentationModes
- `WidgetPlacement`: fractional coordinate system (0–1) with x, y, width, height, zIndex. Includes `clamped()`, `snapped(to:rows:)`, `rect(in:)`, and `defaultPlacement(index:size:presentationMode:)` helpers
- `DashboardWidgetInstance`: a placed widget with UUID, widgetID, placement, presentationMode, configurationData (opaque `Data` blob)
- `DashboardState`: layoutMode, activeThemeID, selectedWidgetIDs, widgets array
- `WidgetContext`: theme + layoutMode + containerSize, passed to widget views
- `DashboardWidget` protocol: associated-type `Configuration: Codable & Hashable`, requires `static var metadata`, `static var defaultConfiguration`, `static func makeView(configuration:configuration:context:) -> AnyView`, and optionally `makeSettingsView(configuration:) -> AnyView`

### WidgetRegistry.swift

`@MainActor` type-erased registry. Widgets are registered via `registry.register(MyWidget.self)`. Internally wraps each widget as an `AnyWidgetDescriptor` that stores metadata, default config as `Data`, and closures for `makeView` / `makeSettingsView`. The closures handle Codable encode/decode bridging via `JSONEncoder`/`JSONDecoder`, falling back to `defaultConfiguration` on decode failure.

### DashboardStore.swift

`@MainActor ObservableObject`, the central state manager:
- On init, attempts `persistence.load()`; falls back to `bootstrapState()` which creates instances for every registered widget
- `bootstrapState()` assigns `matrix-rain` and `world-activity-map` as `.background`; all others as `.floating`. Default layout mode is `.hybrid`.
- `mergedState()` reconciles persisted state with the registry: adds any newly-registered widgets not in the persisted state
- Persistence is NOT debounced — `persist()` writes synchronously on every mutation
- Provides CRUD for widgets, placement updates (snapped in tiled mode, clamped otherwise), selection management, z-index ordering, duplicate, and layout reset

### DashboardTheme.swift

`DashboardTheme` with a `Palette` of hex colors + `glowIntensity`. Four built-in themes in `DashboardThemes.all`: classic-green-terminal, amber-crt, ice-blue, red-alert. Includes `Color(hex:)` extension supporting 6-digit and 8-digit hex. Theme also exposes `headlineFont` and `bodyFont` (both monospaced).

### DashboardPersistence.swift

Thin JSON file persistence with pretty-printed + sorted-keys output. `live()` resolves to `ApplicationSupport/TotallyNotHacking/dashboard-state.json`, creating directories as needed.

## UI Layer Details

### DashboardShellView.swift

The entire dashboard rendering and control:
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

### WidgetChromeHelpers.swift

`dashboardPanelStyle(theme:)` View extension for panel chrome.

## Widget System

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

### Performance Conventions for Widget Rendering

- Continuous animations use `TimelineView(.animation(minimumInterval:paused:))` with the timeline date as the animation driver (no timers)
- Custom drawing uses `Canvas` with `context.fill(Path, with:)` and `context.draw(Text, at:)`
- Background widgets use `.drawingGroup()` to flatten into a single layer
- Helper functions in `WidgetSupport.swift` generate deterministic pseudo-random data: `waveformValues(count:phase:seed:amplitude:)`, `simulatedLogLine(prefix:index:phase:)`, `hexStream(seed:rows:columns:phase:)`, `glyphStream(for:)`, `asciiBar(level:width:filled:empty:)`, `asciiMeter(level:width:head:)`, `matrixGlyph(at:phase:)`, and the `glowingText(theme:)` View modifier

### Registered Widgets

Registered in `DefaultWidgetCatalog.registerAll(into:)`: `TerminalStreamWidget`, `MatrixRainWidget`, `FakeNetworkMonitorWidget`, `WorldActivityMapWidget`, `RadarScreenWidget`, `CPUUsageSimulatorWidget`, `LogViewerWidget`, `HexDumpViewerWidget`, `ScrollingErrorConsoleWidget`, `FakeSatelliteTrackerWidget`.

---

# Widget Contract

All widgets must conform to a common widget protocol (`DashboardWidget`).

Widgets should provide:

* Metadata
* Configuration (Codable & Hashable)
* SwiftUI view
* Settings view (optional)
* Preview support

Widgets should be discoverable through registration.

Avoid giant switch statements.

Avoid widget-specific logic inside dashboard code.

---

# Layout Model

Support:

## Tiled

Grid-based dashboard. Placement is snapped to a grid (12×8 or 16×10) in tiled mode.

## Floating

Desktop-like windows. Placement is clamped to stay within bounds.

## Hybrid

Background layer plus floating widgets.

A widget may declare itself capable of:

* Background mode
* Tiled mode
* Floating mode

Not all widgets must support every mode.

## Coordinate System

All widget placement uses a fractional 0–1 coordinate system that maps to the container size at render time. `WidgetPlacement.rect(in:)` converts to `CGRect`. The `clamped()` method ensures width/height stay in [0.08, 1] and position stays within bounds. `snapped(to:rows:)` aligns to a grid for tiled mode.

---

# Background Widgets

Background widgets occupy an entire dashboard layer.

Examples:

* Matrix rain
* Animated world map
* Radar sweep
* Signal visualization

Background widgets should be optimized for continuous rendering.

Floating widgets may appear above them.

---

# Theme System

Themes are data-driven.

Avoid hardcoded colors throughout the UI.

Use theme tokens.

Examples:

* terminalGreen
* terminalAmber
* alertRed
* iceBlue

All visual styling should originate from the active theme.

Each theme has a `Palette` of hex colors and a `glowIntensity` value.

Adding a theme should not require modifying existing widgets.

Built-in themes: classic-green-terminal, amber-crt, ice-blue, red-alert.

---

# State Management

Use MVVM.

Views should remain lightweight.

Business logic belongs in view models or services.

Persist user configuration automatically.

Persisted state is stored as JSON in `ApplicationSupport/TotallyNotHacking/dashboard-state.json`.

Persistence writes synchronously on every mutation (not debounced).

---

# Performance

Prioritize smooth animation.

Avoid unnecessary view invalidation.

Background widgets should remain efficient.

Target stable 60 FPS.

Use `TimelineView(.animation(minimumInterval:paused:))` for continuous animations instead of timers.

Use `Canvas` for custom drawing.

Use `.drawingGroup()` on background widgets to flatten rendering.

---

# Adding A New Widget

A new widget should require:

1. Widget folder creation.
2. Widget implementation (conform to `DashboardWidget`).
3. Widget registration (add to `DefaultWidgetCatalog.registerAll(into:)`).

No other framework modifications should be necessary.

If adding a widget requires editing many unrelated files, improve the architecture first.

Update the test assertion for the expected widget count after adding a new widget.

---

# Build & Run

- Open `Totally Not Hacking.xcodeproj` in **Xcode 16+**
- Run the `Totally Not Hacking` scheme on an **iPadOS simulator or device**
- No CLI build tools, Package.swift, or Makefile — this is Xcode-only
- Tests use the **Swift Testing** framework (`@Test` macro, `#expect`). Run with ⌘U in Xcode. No XCTest.

---

# Key Constraints

- **iPad-only** — not designed for iPhone or Mac
- **No real functionality** — everything is simulated entertainment. Do not add real networking, scanning, intrusion, or credential handling
- **Xcode 16+ required**

---

# Non-Goals

Do not implement:

* Real hacking tools
* Port scanners
* Vulnerability scanners
* Credential collection
* Network attacks
* Security testing utilities
* Packet capture
* Exploit frameworks

Everything displayed should be simulated.

---

# Visual Style

The application should feel like:

* Hollywood hacker movies
* Sci-fi command centers
* Retro terminals
* Cyberpunk dashboards

Visuals should prioritize entertainment and atmosphere over realism.

Absurdity is encouraged.

"Dramatic" is often better than "accurate."

---

# Commit Messages

Always use Conventional Commits for git commit messages.

Types: `feat`, `fix`, `build`, `chore`, `ci`, `docs`, `style`, `refactor`, `perf`, `test`.

Format: `<type>[optional scope]: <description>`

Breaking changes use `!` before `:` or a `BREAKING CHANGE:` footer.

---

# Branch Names

Use conventional branch names such as `feat/...`, `fix/...`, `docs/...`, `chore/...`, or `ci/...`.
