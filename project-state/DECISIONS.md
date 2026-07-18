# Decisions

## Architectural

### SwiftUI + MVVM

Choose SwiftUI for the UI layer with `@MainActor ObservableObject` view models. Business logic belongs in view models/services, not views.

### JSON File Persistence

Use JSON files in the Application Support directory for persisting dashboard state. Synchronous writes on every mutation (not debounced). Pretty-printed sorted-key output for readability.

### `Color(hex:)` Extension

Use 6-digit and 8-digit hex color strings to define theme palettes. Avoid hardcoded colors in views — all color originates from the active theme.

### Monospaced Typography

All dashboard text uses `.system(.headline/.body, design: .monospaced)` for the retro-terminal aesthetic. No serif or sans-serif fonts.

## Theming

### 6 Built-in Themes

Provide 6 themes out of the box covering the classic hacker-movie palette:
- Classic Green Terminal (default)
- Amber CRT
- Ice Blue
- Red Alert
- Phosphor White
- Cyberpunk Neon

### Data-Driven Themes

Themes are `Codable` structs with a `Palette` of 7 color tokens. Adding a theme requires no view changes — only appending to `DashboardThemes.all`.

## Rendering

### Canvas for Custom Drawing

Use SwiftUI `Canvas` for grid lines, CRT scanlines, and any procedural graphics. Avoid overlay shapes or SpriteKit for these effects.

### `drawingGroup()` for Backgrounds

Use `.drawingGroup()` on the CRT scanline overlay to flatten rendering into a single layer for performance.

### Fixed 3-Pane Layout (Current)

The current UI uses a 4-layer ZStack with 3 fixed panes (top terminal, bottom-left pseudo-code, bottom-right doom fire). This is interim — the final architecture will use a `NavigationSplitView` with a widget registry and tiled/floating/hybrid layout.

## Testing

### Swift Testing Framework

Use the Swift Testing framework (`@Test`, `#expect`) instead of XCTest for unit tests. UI tests remain in XCTest for launch testing.

## Non-Goals

- No real networking, scanning, intrusion, or credential handling
- No external dependencies beyond Foundation and SwiftUI
- No Package.swift or CLI build tooling — Xcode project only
- iPad-only — not designed for iPhone or Mac
