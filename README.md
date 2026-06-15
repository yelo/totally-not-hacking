# Totally Not Hacking

Totally Not Hacking is a native SwiftUI iPadOS dashboard app that simulates fictional movie-style hacker interfaces. It is intentionally visual-only: no real hacking, networking, intrusion, scanning, or credential handling exists here.

## Highlights

- iPad-first SwiftUI app
- Registry-driven widget system
- Extensible theme engine
- Tiled, floating, and hybrid dashboard modes
- Fully local simulation data

## Architecture

The app is organized around a small Core layer and a set of self-contained widgets:

- **Core**: widget contracts, registry, theme types, layout models, persistence, and dashboard state
- **Widgets**: individual simulated widgets that register themselves with the dashboard
- **UI**: the dashboard shell, canvas, control panel, and widget chrome

Adding a new widget should only require:

1. Creating a widget folder
2. Implementing `DashboardWidget`
3. Registering it in the catalog

## Layout Modes

- **Tiled Dashboard**: grid-based, snap-friendly layout
- **Floating Desktop**: freeform movable and resizable windows
- **Hybrid Mode**: background widgets with floating widgets above them

## Themes

Built-in themes:

- Classic Green Terminal
- Amber CRT
- Ice Blue
- Red Alert

Themes control palette, glow, and typography tokens.

## Initial Widgets

- Terminal Stream
- Matrix Rain
- Fake Network Monitor
- World Activity Map
- Radar Screen
- CPU Usage Simulator
- Log Viewer
- Hex Dump Viewer
- Scrolling Error Console
- Fake Satellite Tracker

## Requirements

- Xcode 16+
- iPadOS simulator or device

## Run

Open `Totally Not Hacking.xcodeproj` in Xcode and run the `Totally Not Hacking` scheme.

## Non-Goals

This app does not perform real security work. Everything displayed is simulated for entertainment only.
