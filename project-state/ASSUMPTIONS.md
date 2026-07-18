# Assumptions

Updated: 2026-07-18

## Active

| ID | Added | Assumption | Confidence | Source | How to verify |
|---|---|---|---:|---|---|
| A-001 | 2026-07-18 | A `DashboardWidget` protocol exists that widgets conform to | Low | AGENTS.md architecture description | Search for `protocol DashboardWidget` in `Core/` |
| A-002 | 2026-07-18 | A `WidgetRegistry` type exists for registering widgets | Low | AGENTS.md | Search for `class WidgetRegistry` or `struct WidgetRegistry` |
| A-003 | 2026-07-18 | A `DefaultWidgetCatalog` exists and is called from the app entry point | Low | AGENTS.md | Search for `DefaultWidgetCatalog` in `.swift` files |
| A-004 | 2026-07-18 | Widgets live in per-widget subdirectories under `Widgets/` | Low | AGENTS.md layer description | List `Widgets/` directory contents |
| A-005 | 2026-07-18 | The dashboard shell uses `NavigationSplitView` with sidebar/detail | Low | AGENTS.md UI layer description | Inspect `DashboardShellView.swift` for `NavigationSplitView` |
| A-006 | 2026-07-18 | The layout system supports tiled, floating, and hybrid modes | Low | AGENTS.md Layout Model section | Search for `layoutMode` or `DashboardLayoutMode` in code |
| A-007 | 2026-07-18 | `WidgetPlacement` with fractional coordinate system is implemented | Low | AGENTS.md Coordinate System section | Search for `struct WidgetPlacement` |
| A-008 | 2026-07-18 | `WidgetChromeView` with title bar and glow borders exists | Low | AGENTS.md UI layer description | Search for `WidgetChromeView` |
| A-009 | 2026-07-18 | Drag-to-move and resize handle are implemented for widgets | Low | AGENTS.md | Search for `DragGesture` or resize handle logic |
| A-010 | 2026-07-18 | 10 built-in widgets are registered in `DefaultWidgetCatalog` | Low | AGENTS.md Widget System section | List files in `Widgets/` directory |
| A-011 | 2026-07-18 | Each widget has its own `Configuration` type conforming to `Codable & Hashable` | Low | AGENTS.md widget pattern | Inspect each widget file for `struct Configuration` |
| A-012 | 2026-07-18 | Each widget implements `makeView(configuration:context:)` | Low | AGENTS.md widget pattern | Inspect each widget file for `makeView` |
| A-013 | 2026-07-18 | Tests assert the expected widget count from `DefaultWidgetCatalog` | Low | AGENTS.md | Inspect test file for widget count assertion |
| A-014 | 2026-07-18 | `FloatingWidgetConnectorOverlay` with animated canvas lines exists | Low | AGENTS.md UI layer description | Search for `FloatingWidgetConnectorOverlay` |
| A-015 | 2026-07-18 | `DashboardState` includes `layoutMode`, `activeThemeID`, `selectedWidgetIDs`, and `widgets` array | Low | AGENTS.md Core layer section | Inspect `DashboardModels.swift` for `DashboardState` properties |
| A-016 | 2026-07-18 | `DashboardStore.bootstrapState()` assigns some widgets as `.background` and others as `.floating` | Low | AGENTS.md DashboardStore description | Search for `bootstrapState` in code |
| A-017 | 2026-07-18 | `DashboardStore.mergedState()` reconciles persisted state with registry | Low | AGENTS.md DashboardStore description | Search for `mergedState` in code |
| A-018 | 2026-07-18 | `DashboardBackdropGrid` supports both 12×8 and 16×10 grid sizes | Low | AGENTS.md UI layer description | Inspect `DashboardBackdropGrid` for grid dimension parameters |
| A-019 | 2026-07-18 | `WidgetContext` struct exists with theme, layoutMode, and containerSize | Low | AGENTS.md Core layer section | Search for `struct WidgetContext` |
| A-020 | 2026-07-18 | `DashboardWidgetInstance` struct exists with UUID, widgetID, placement, presentationMode, configurationData | Low | AGENTS.md Core layer section | Search for `struct DashboardWidgetInstance` |

## Resolved

| ID | Added | Resolved | Assumption | Result | Evidence |
|---|---|---|---|---|---|
