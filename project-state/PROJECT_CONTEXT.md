# Project Context

Updated: 2026-07-18

Latest fix: added opencode.json with sourcekit-lsp LSP configuration for Swift files.

Latest fix: replaced AGENTS.md with a process-oriented workflow format (before/during/finish checklist) and added `project-state/` directory with 4 tracking files (PROJECT_CONTEXT.md, ASSUMPTIONS.md, TODO.md, DECISIONS.md).

Latest fix: merged CLAUDE.md into AGENTS.md for tool-agnostic agent configuration. Single source of truth for all agent tools — includes file-by-file architecture breakdown, build/run instructions, coordinate system, and key constraints.

Latest fix: trimmed README.md to install/run/usage only (down from 68 to 24 lines). Removed architecture descriptions, widget listings, and layout mode docs.

Previous fix: complete TUI overhaul — replaced the earlier layout with a fixed 4-layer ZStack (MatrixRain background, CRT scanlines, backdrop grid, 3 content panes).

## Current State

The app is an iPadOS SwiftUI dashboard that simulates movie-style hacker interfaces. All data is purely simulated — no real networking, scanning, or intrusion.

### Rendering Pipeline

`DashboardShellView` builds a 4-layer ZStack:

1. **Background:** `MatrixRainWidgetView` full-screen animation, `.ignoresSafeArea()`, `.allowsHitTesting(false)`
2. **CRT effect:** `CRTScanlineOverlay` — Canvas-drawn alternating 1px dark lines at 4px spacing, `.drawingGroup()`
3. **Grid:** `DashboardBackdropGrid` — 12×8 Canvas grid with horizontal accent scanline at 4–6% opacity
4. **Content:** 3 fixed panes — `TopTerminalPane` (44% height) + HStack of `BottomLeftPane` / `BottomRightPane` (54% height)

A theme cycle button sits top-right calling `store.cycleTheme()`.

### State Management

`DashboardStore`: `@MainActor final class`, `ObservableObject`. Owns `@Published var state: DashboardState` (Codable struct with `activeThemeID: String`) and `@Published var persistenceMessage: String?`. On init, tries `persistence.load()` — falls back to default state with first theme. `setTheme()` / `cycleTheme()` mutate state and persist synchronously.

### Themes

6 themes via `DashboardThemes.all`: classic-green-terminal (default), amber-crt, ice-blue, red-alert, phosphor-white, cyberpunk-neon.

Each has a `Palette` of 7 hex color tokens (`primaryHex`, `secondaryHex`, `accentHex`, `backgroundHex`, `surfaceHex`, `textHex`, `glowHex`) plus `glowIntensity`. Computed `scanlineIntensity = 0.03 + (palette.glowIntensity × 0.035)`. All typography is monospaced (`.system(.headline, design: .monospaced)` / `.system(.body, design: .monospaced)`). Theme `id` is the stable key; views read the active theme from `DashboardStore.activeTheme`.

### Persistence

`DashboardPersistence` reads/writes `DashboardState` as pretty-printed sorted-key JSON to `ApplicationSupport/TotallyNotHacking/dashboard-state.json`. The `live()` factory creates the directory if needed. Writes are synchronous on every mutation (not debounced).

### Widget System

Currently minimal — only `MatrixRainWidgetView` exists as a standalone view (no `DashboardWidget` protocol yet, no `WidgetRegistry`, no per-widget subdirectories). `WidgetSupport.swift` provides shared helpers used across the UI:

- ASCII graphics: `asciiBar(level:width:filled:empty:)`, `asciiMeter(level:width:head:)`, `matrixGlyph(at:phase:)`, `tuiBar`, `tuiMeter`, `tuiDivider`
- Data generation: `waveformValues(count:phase:seed:amplitude:)`, `simulatedLogLine(prefix:index:phase:)`, `hexStream(seed:rows:columns:phase:)`, `glyphStream(for:)`
- View modifiers: `glowingText(theme:)`, `crtGlow`

### Testing

5 unit tests using Swift Testing (`@Test`, `#expect`):

| Test | What it verifies |
|---|---|
| `dashboardStateRoundTrips()` | JSON encode/decode round trip preserves `activeThemeID` |
| `storeInitializesWithDefaultTheme()` | Default theme is classicGreen, `themes.count == 6` |
| `asciiHelpersProduceExpectedShapes()` | `asciiBar`, `asciiMeter`, `matrixGlyph` return expected strings |
| `tuiHelpersProduceExpectedShapes()` | `tuiBar`, `tuiMeter`, `tuiDivider` return expected strings |
| `themeCountIsSix()` | `DashboardThemes.all.count == 6` |

## Structure

- `Totally_Not_HackingApp.swift`: `@main` entry point — creates `DashboardStore` with `DashboardPersistence.live()`, injects as `@EnvironmentObject` into `ContentView`.
- `Core/DashboardModels.swift`: `DashboardState` (Codable, Hashable) with `activeThemeID`.
- `Core/DashboardPersistence.swift`: JSON file read/write with `live()` factory.
- `Core/DashboardStore.swift`: Central `@MainActor ObservableObject` — theme management, cycle, persistence.
- `Core/DashboardTheme.swift`: `DashboardTheme`, `Palette` (7 color tokens), 6 built-in themes, `Color(hex:)` extension (6-digit and 8-digit hex).
- `UI/DashboardShellView.swift`: 4-layer ZStack shell, `CRTScanlineOverlay`, `DashboardBackdropGrid`, theme cycle button.
- `UI/TerminalPanes.swift`: `TopTerminalPane`, `BottomLeftPane`, `BottomRightPane` with load averages, pseudo-code stream, doom fire thermal viz.
- `UI/WidgetChromeHelpers.swift`: `dashboardPanelStyle` view modifier for consistent inner panel styling.
- `Widgets/MatrixRainWidget.swift`: Matrix rain animation — configurable columns/speed/brightness, `TimelineView(.animation(minimumInterval: 0.05))`, `Canvas`.
- `Widgets/WidgetSupport.swift`: Shared ASCII/CRT rendering helpers and view modifiers.
- `Totally_Not_HackingTests/Totally_Not_HackingTests.swift`: 5 Swift Testing tests.
- `Totally_Not_HackingUITests/Totally_Not_HackingUITests.swift`: XCTest launch test template.
- `Totally_Not_HackingUITests/Totally_Not_HackingUITestsLaunchTests.swift`: XCTest launch screenshot test.
- `opencode.json`: opencode configuration — enables sourcekit-lsp LSP for `.swift` files.
- `AGENTS.md`: Agent operating instructions with before/during/finish workflow.
- `project-state/`: Project context, assumptions, todo, decisions.
- `README.md`: Install/run/usage only.
- `Totally Not Hacking.xcodeproj`: Xcode project (no Package.swift or CLI tooling).
- `.agents/skills/`: Reusable agent skills (conventional-commits, swiftui, swiftui-review).
- `.github/workflows/release-please.yml`: CI — Release Please on push to `main`.
- `.github/CODEOWNERS`: `@yelo` owns all files.
