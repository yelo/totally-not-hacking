# Assumptions

Updated: 2026-07-20

## Active

(none)

## Deferred (widget-centric architecture, 2026-07-06)

These assumptions describe a future widget system deferred in favor of the current fixed 3-pane layout.
See `DECISIONS.md` 2026-07-06 for rationale.

| ID | Added | Assumption |
|---|---|---|
| A-001 | 2026-07-18 | A `DashboardWidget` protocol exists that widgets conform to |
| A-002 | 2026-07-18 | A `WidgetRegistry` type exists for registering widgets |
| A-003 | 2026-07-18 | A `DefaultWidgetCatalog` exists and is called from the app entry point |
| A-004 | 2026-07-18 | Widgets live in per-widget subdirectories under `Widgets/` |
| A-005 | 2026-07-18 | The dashboard shell uses `NavigationSplitView` with sidebar/detail |
| A-006 | 2026-07-18 | The layout system supports tiled, floating, and hybrid modes |
| A-007 | 2026-07-18 | `WidgetPlacement` with fractional coordinate system is implemented |
| A-008 | 2026-07-18 | `WidgetChromeView` with title bar and glow borders exists |
| A-009 | 2026-07-18 | Drag-to-move and resize handle are implemented for widgets |
| A-010 | 2026-07-18 | 10 built-in widgets are registered in `DefaultWidgetCatalog` |
| A-011 | 2026-07-18 | Each widget has its own `Configuration` type conforming to `Codable & Hashable` |
| A-012 | 2026-07-18 | Each widget implements `makeView(configuration:context:)` |
| A-013 | 2026-07-18 | Tests assert the expected widget count from `DefaultWidgetCatalog` |
| A-014 | 2026-07-18 | `FloatingWidgetConnectorOverlay` with animated canvas lines exists |
| A-015 | 2026-07-18 | `DashboardState` includes `layoutMode`, `activeThemeID`, `selectedWidgetIDs`, and `widgets` array |
| A-016 | 2026-07-18 | `DashboardStore.bootstrapState()` assigns some widgets as `.background` and others as `.floating` |
| A-017 | 2026-07-18 | `DashboardStore.mergedState()` reconciles persisted state with registry |
| A-018 | 2026-07-18 | `DashboardBackdropGrid` supports both 12×8 and 16×10 grid sizes |
| A-019 | 2026-07-18 | `WidgetContext` struct exists with theme, layoutMode, and containerSize |
| A-020 | 2026-07-18 | `DashboardWidgetInstance` struct exists with UUID, widgetID, placement, presentationMode, configurationData |

## Resolved

| ID | Added | Resolved | Assumption | Result | Evidence |
|---|---|---|---|---|---|
