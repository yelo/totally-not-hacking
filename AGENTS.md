# AGENTS.md

## Project

Totally Not Hacking

A humorous iPadOS dashboard application that simulates fictional movie-style hacker interfaces.

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

---

# Widget Contract

All widgets must conform to a common widget protocol.

Widgets should provide:

* Metadata
* Configuration
* SwiftUI view
* Preview support

Widgets should be discoverable through registration.

Avoid giant switch statements.

Avoid widget-specific logic inside dashboard code.

---

# Layout Model

Support:

## Tiled

Grid-based dashboard.

## Floating

Desktop-like windows.

## Hybrid

Background layer plus floating widgets.

A widget may declare itself capable of:

* Background mode
* Tiled mode
* Floating mode

Not all widgets must support every mode.

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

Adding a theme should not require modifying existing widgets.

---

# State Management

Use MVVM.

Views should remain lightweight.

Business logic belongs in view models or services.

Persist user configuration automatically.

---

# Performance

Prioritize smooth animation.

Avoid unnecessary view invalidation.

Background widgets should remain efficient.

Target stable 60 FPS.

---

# Adding A New Widget

A new widget should require:

1. Widget folder creation.
2. Widget implementation.
3. Widget registration.

No other framework modifications should be necessary.

If adding a widget requires editing many unrelated files, improve the architecture first.

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

# Commit Messages

Always use Conventional Commits for git commit messages.

---

# Branch Names

Use conventional branch names such as `feat/...`, `fix/...`, `docs/...`, `chore/...`, or `ci/...`.
