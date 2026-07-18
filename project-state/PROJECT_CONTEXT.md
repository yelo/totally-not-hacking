# Project Context

## Overview

Totally Not Hacking is a native SwiftUI iPadOS dashboard app that simulates fictional movie-style hacker interfaces. All data is simulated — no real networking, scanning, or intrusion.

## Tech Stack

- **Language:** Swift
- **UI Framework:** SwiftUI
- **Minimum Platform:** iPadOS, Xcode 16+
- **Testing:** Swift Testing framework (`@Test`, `#expect`)
- **Persistence:** JSON file at `ApplicationSupport/TotallyNotHacking/dashboard-state.json`
- **Dependencies:** None (pure SwiftUI + Foundation)

## File Map

```
Totally Not Hacking/
├── Core/
│   ├── DashboardModels.swift        — DashboardState struct (Codable, Hashable)
│   ├── DashboardPersistence.swift   — JSON file read/write
│   ├── DashboardStore.swift         — @MainActor ObservableObject state manager
│   └── DashboardTheme.swift         — DashboardTheme + Palette + 6 built-in themes + Color(hex:)
├── UI/
│   ├── DashboardShellView.swift     — ContentView → DashboardShellView (4-layer ZStack)
│   ├── TerminalPanes.swift          — 3 fixed pane views (top terminal, bottom pseudo-code, doom fire)
│   └── WidgetChromeHelpers.swift    — dashboardPanelStyle view modifier
├── Widgets/
│   ├── MatrixRainWidget.swift       — Matrix rain animation with configurable columns/speed/brightness
│   └── WidgetSupport.swift          — Shared helpers (waveformValues, simulatedLogLine, hexStream, asciiBar, etc.)
├── Totally_Not_HackingApp.swift     — @main entry point
├── Assets.xcassets/                 — AccentColor, AppIcon
```

```
Totally Not HackingTests/
└── Totally_Not_HackingTests.swift   — 5 tests (state round-trip, store init, ASCII shapes, TUI shapes, theme count)
```

```
Totally Not HackingUITests/
├── Totally_Not_HackingUITests.swift
└── Totally_Not_HackingUITestsLaunchTests.swift
```

## Current Architecture

### App Entry Point

`Totally_Not_HackingApp.swift` creates a `DashboardStore` with `DashboardPersistence.live()`, injects it as an `@EnvironmentObject` into `ContentView`.

### Rendering Pipeline

`DashboardShellView` builds a 4-layer ZStack:

1. **Background:** `MatrixRainWidgetView` (full-screen, ignored safe areas, allowsHitTesting false)
2. **CRT Effect:** `CRTScanlineOverlay` — Canvas-drawn alternating 1px dark lines at 4px spacing, `.drawingGroup()`
3. **Grid:** `DashboardBackdropGrid` — 12×8 Canvas grid with horizontal accent scanline
4. **Content:** 3 fixed panes — `TopTerminalPane` (44% height) + `HStack` of `BottomLeftPane` / `BottomRightPane` (54% height)

A theme cycle button sits in the top-right corner calling `store.cycleTheme()`.

### State Management

- `DashboardStore`: `@MainActor final class`, `ObservableObject`
- Owns `@Published var state: DashboardState` and `@Published var persistenceMessage: String?`
- On init, tries `persistence.load()` — falls back to default state
- `setTheme()` / `cycleTheme()` mutate state and persist

### Themes

6 built-in themes (classic-green-terminal, amber-crt, ice-blue, red-alert, phosphor-white, cyberpunk-neon). Each has a `Palette` of 7 hex color tokens + `glowIntensity`. Theme provides `headlineFont` and `bodyFont` (monospaced), and computed `scanlineIntensity`.

### Persistence

`DashboardPersistence` reads/writes `DashboardState` as pretty-printed sorted-key JSON. The `live()` factory creates the `ApplicationSupport/TotallyNotHacking/` directory if needed.

### Widget System

Currently minimal — only `MatrixRainWidgetView` exists as a standalone view (not protocol-based). `WidgetSupport.swift` provides shared rendering helpers used across the UI.

## Tests

5 unit tests using Swift Testing (`#expect` macro):
- `dashboardStateRoundTrips()` — JSON encode/decode round trip
- `storeInitializesWithDefaultTheme()` — verifies default theme + 6 themes exist
- `asciiHelpersProduceExpectedShapes()` — asciiBar, asciiMeter, matrixGlyph
- `tuiHelpersProduceExpectedShapes()` — tuiBar, tuiMeter, tuiDivider
- `themeCountIsSix()` — DashboardThemes.all.count == 6

## Key Design Notes

- No `DashboardWidget` protocol exists yet
- No `WidgetRegistry` or `DefaultWidgetCatalog` exists
- No widget subdirectories — all widget code is flat in `Widgets/`
- The shell uses fixed panes, not `NavigationSplitView`, tiled/floating/hybrid layout, or widget chrome
- Only MatrixRain is implemented as a widget; 9 others described in docs don't exist yet
