# Project Context

Updated: 2026-07-20

Latest fix: refactor — split `TerminalPanes.swift` (388 lines) into `TopTerminalPane.swift`, `BottomLeftPane.swift`, `BottomRightPane.swift`, `FireSimulation.swift`, and `PaneFrame.swift`. Extracted overlay views into `UI/Overlays/`. Removed `WidgetChromeHelpers.swift` (empty dead file) and `ContentView` bridge wrapper. Made data generators internal for testability. Extracted magic numbers to named constants. Fixed `fireBandColor` to use theme accent/primary instead of hardcoded `.white`. Added `assertionFailure` on malformed hex in `hexToColor`. Grew test suite from 5 to 20 tests covering store cycle/persistence, data generators, and fire simulation.

Previous fix: perf — cached Color values in Palette (precomputed once, removed per-access Scanner allocations), replaced fireField 2D array with flat [Double] buffer (0 allocations per frame vs 46), added .drawingGroup() to MatrixRain Canvas, replaced String(format:) with string interpolation in hot render loops, debounced persistence writes (0.3s), optimized scroll-to-bottom guard, removed dead code.

## Current State

The app is an iPadOS SwiftUI dashboard that simulates movie-style hacker interfaces. All data is purely simulated — no real networking, scanning, or intrusion.

### Rendering Pipeline

`DashboardShellView` builds a 5-layer ZStack:

1. **Background:** `MatrixRainWidgetView` full-screen animation, `.ignoresSafeArea()`, `.allowsHitTesting(false)`
2. **CRT effect:** `CRTScanlineOverlay` — Canvas-drawn alternating 1px dark lines at 4px spacing, `.drawingGroup()`
3. **Grid:** `DashboardBackdropGrid` — 12×8 Canvas grid with horizontal accent scanline
4. **Overlays:** `EdgeVignetteOverlay` (radial gradient) + `ChromaticEdgeFringe` (red/blue edge lines)
5. **Content:** 3 fixed panes — `TopTerminalPane` (44% height) + HStack of `BottomLeftPane` / `BottomRightPane` (54% height)

A theme cycle button sits top-right calling `store.cycleTheme()`.

### State Management

`DashboardStore`: `@MainActor final class`, `ObservableObject`. Owns `@Published var state: DashboardState` (Codable struct with `activeThemeID: String`). On init, tries `persistence.load()` — falls back to default state with first theme. Falls back when persisted theme ID is missing from the registry. Persisted writes are debounced (0.3s) via cancellable `Task`.

### Themes

6 themes via `DashboardThemes.all`: classic-green-terminal (default), amber-crt, ice-blue, red-alert, phosphor-white, cyberpunk-neon.

Each has a `Palette` with 7 hex color tokens + precomputed `Color` stored properties. Custom `Codable` encodes only hex strings. `Hashable`/`Equatable` compare hex values only.

### Persistence

`DashboardPersistence` reads/writes `DashboardState` as pretty-printed sorted-key JSON to `ApplicationSupport/TotallyNotHacking/dashboard-state.json`. Writes debounced (0.3s).

## Structure

- `Totally_Not_HackingApp.swift`: `@main` entry point — creates `DashboardStore`, injects as `@EnvironmentObject` into `DashboardShellView`.
- `Core/DashboardModels.swift`: `DashboardState` (Codable, Hashable) with `activeThemeID`.
- `Core/DashboardPersistence.swift`: JSON file read/write with `live()` factory.
- `Core/DashboardStore.swift`: Central `@MainActor ObservableObject` — theme cycle, debounced persistence.
- `Core/DashboardTheme.swift`: `DashboardTheme`, `Palette` (precomputed Colors + custom Codable), 6 built-in themes, `hexToColor` with malformed hex assertion.
- `UI/DashboardShellView.swift`: 5-layer ZStack shell + theme cycle button. Reads store via `@EnvironmentObject`.
- `UI/PaneFrame.swift`: Reusable pane chrome wrapper with header strip, border, and background.
- `UI/TopTerminalPane.swift`: Load averages, breach tracks, chatter lines + data generators (`fmt2`, `simulatedLoadAverages`, `breachTracks`, `chatterLines`, `pad2`, `pad4Hex`, `hexNibble`).
- `UI/BottomLeftPane.swift`: Auto-scrolling pseudo-code stream + `codeLine`, `pad2Hex`, `lineColor` generators.
- `UI/BottomRightPane.swift`: Doom fire thermal visualization Canvas.
- `UI/FireSimulation.swift`: `fireField`, `doomDecay`, `fireBand`, `fireBandColor` — all internal (testable). Hottest bands use theme colors.
- `UI/Overlays/CRTScanlineOverlay.swift`: Animated scanline Canvas overlay.
- `UI/Overlays/EdgeVignetteOverlay.swift`: Radial gradient vignette.
- `UI/Overlays/ChromaticEdgeFringe.swift`: CRT chromatic aberration edge lines.
- `UI/Overlays/DashboardBackdropGrid.swift`: 12×8 Canvas grid.
- `Widgets/MatrixRainWidget.swift`: Matrix rain animation with Canvas + `.drawingGroup()`.
- `Widgets/WidgetSupport.swift`: Shared ASCII/CRT rendering helpers and view modifiers.
- `Totally_Not_HackingTests/Totally_Not_HackingTests.swift`: 20 Swift Testing tests (state round-trip, store init/cycle/persistence/fallback, helpers, data generators, fire simulation).
- `Totally_Not_HackingUITests/Totally_Not_HackingUITests.swift`: XCTest launch test template.
- `Totally_Not_HackingUITests/Totally_Not_HackingUITestsLaunchTests.swift`: XCTest launch screenshot test.
