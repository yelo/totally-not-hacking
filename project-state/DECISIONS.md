# Decisions

Record decisions under the date they were made. If a later decision supersedes an earlier one, add the newer entry under its own date rather than editing history in place.

## 2026-07-20 (performance optimization round)

- **Precompute `Color` values in `Palette` as stored properties.** Colors are computed once on init via `hexToColor()`, stored alongside hex strings. Custom `Codable` only encodes/decodes hex strings; custom `Hashable`/`Equatable` compare hex values only. Eliminates per-access `Scanner` allocations that occurred on every computed color property read during rendering.
- **Use flat `[Double]` buffer for Doom Fire instead of `[[Double]]` 2D array.** Single allocation with manual index math (`row * cols + col`). Goes from 46 array allocations per frame at 20fps to 0.
- **Add `.drawingGroup()` to MatrixRain `Canvas`.** Matches the pattern already applied to CRT scanline overlay and backdrop grid, reducing compositing cost for ~1,600 glyph draws per frame.
- **Replace `String(format:)` with string interpolation in hot rendering loops.** `chatterLines()` (12 lines, every 0.12s), `codeLine()` (60 lines, every 0.12s), and `statusLines()` now use native Swift string interpolation and custom zero-padding helpers (`pad2`, `pad2Hex`) instead of `NSString`-backed `String(format:)`. Eliminates ~720 format calls/sec.
- **Debounce persistence writes with 0.3s delay.** `DashboardStore` uses a cancellable `Task` with `Task.sleep` instead of synchronous writes on every mutation. Rapid theme cycling coalesces into a single write.
- **Guard scroll-to-bottom on actual phase change.** `BottomLeftPane` now only calls `scrollProxy.scrollTo(59)` when `oldPhase != newPhase`, avoiding wasted layout passes.
- **Remove dead code from `WidgetSupport.swift` and `WidgetChromeHelpers.swift`.** Removed `waveformValues`, `simulatedLogLine`, `hexStream`, `glyphStream`, and `dashboardPanelStyle` modifier — none were called by any view. Kept `asciiBar`/`asciiMeter` as they are exercised by tests.

## 2026-07-18 (project-state agent workflow)

- **Replace AGENTS.md with a process-oriented workflow format.** Before/during/finish checklist referencing `project-state/` files. All agent tools read the same file — no more Claude-specific vs generic split.
- **Track agent assumptions in `project-state/ASSUMPTIONS.md`** as a table of hypotheses to verify against the code. Never treat assumptions as truth.
- **Track remaining work in `project-state/TODO.md`** as a prioritized table with area, notes, and done history.
- **Track architectural decisions in `project-state/DECISIONS.md`** chronologically by date. New entries supersede old ones without rewriting history.
- **Keep README.md limited to install/run/usage only.** Remove architecture descriptions, widget listings, and non-goals. Direct agents to `project-state/` for deeper context.

## 2026-07-18 (opencode LSP config)

- **Use `xcrun sourcekit-lsp` as the opencode LSP server for Swift files.** Configured via `opencode.json` with `sourcekit-lsp` key and `swift` extension mapping. The `xcrun` wrapper ensures the correct Xcode toolchain version is used automatically.

## 2026-07-06 (TUI overhaul with fixed 3-pane layout)

- **Adopt a 4-layer ZStack with 3 fixed panes as the interim dashboard shell.** Layers: (1) MatrixRain background, (2) CRT scanlines with `.drawingGroup()`, (3) backdrop grid, (4) content panes (top terminal 44%, bottom-left pseudo-code, bottom-right doom fire thermal viz). This supersedes the earlier widget-centric architecture described in AGENTS.md — the `NavigationSplitView` shell, `WidgetRegistry`, `DashboardWidget` protocol, and tiled/floating/hybrid layout are deferred.

## 2026-06-15 (initial dashboard framework)

- **Choose SwiftUI + MVVM with `@MainActor ObservableObject` view models.** Business logic belongs in view models/services, not views. `DashboardStore` is the central state manager injected as an `@EnvironmentObject`.
- **Persist state as JSON in Application Support directory.** Synchronous writes on every mutation (not debounced). Pretty-printed sorted-key output for readability. `DashboardPersistence` reads/writes `DashboardState` to `ApplicationSupport/TotallyNotHacking/dashboard-state.json`.
- **Use 6-digit and 8-digit hex color strings for theme palettes** via a `Color(hex:)` extension. All visual color originates from the active theme — no hardcoded colors in views.
- **Use monospaced typography throughout.** All dashboard text uses `.system(.headline/.body, design: .monospaced)` for the retro-terminal aesthetic. No serif or sans-serif fonts.
- **Ship 6 built-in themes** covering the classic hacker-movie palette: Classic Green Terminal (default), Amber CRT, Ice Blue, Red Alert, Phosphor White, Cyberpunk Neon.
- **Make themes `Codable` structs with a `Palette` of 7 color tokens.** Adding a theme requires no view changes — only appending to `DashboardThemes.all`. Themes expose `headlineFont`, `bodyFont`, and computed `scanlineIntensity`.
- **Use SwiftUI `Canvas` for custom drawing** (grid lines, CRT scanlines, procedural graphics). Avoid overlay shapes or SpriteKit for these effects.
- **Use `.drawingGroup()` on background overlays** to flatten rendering into a single composited layer for performance. Applied to the CRT scanline overlay.
- **Use Swift Testing framework** (`@Test`, `#expect`) for unit tests. UI tests remain in XCTest for launch testing.
- **Target iPad-only** — not designed for iPhone or Mac.
- **No external dependencies beyond Foundation and SwiftUI.** No Package.swift, SPM, or CLI build tooling — Xcode project only.
- **No real networking, scanning, intrusion, or credential handling.** Everything displayed is simulated for entertainment only.
- **Use Conventional Commits** (`feat:`, `fix:`, `perf:`, `chore:`, etc.) with conventional branch names (`feat/...`, `fix/...`, `docs/...`).
- **Use GitHub Releases via Release Please** for automated changelog and version management on push to `main`.
