import SwiftUI

// MARK: - Content View

struct ContentView: View {
    @EnvironmentObject private var store: DashboardStore

    var body: some View {
        DashboardShellView(store: store)
    }
}

// MARK: - Dashboard Shell

struct DashboardShellView: View {
    @ObservedObject var store: DashboardStore

    var body: some View {
        GeometryReader { proxy in
            let theme = store.activeTheme
            let size = proxy.size

            ZStack(alignment: .topTrailing) {
                // Layer 1: Matrix rain background (full screen)
                MatrixRainWidgetView(
                    configuration: MatrixRainConfiguration(speed: 0.9, brightness: 0.70),
                    theme: theme
                )
                .ignoresSafeArea()
                .allowsHitTesting(false)

                // Layer 2: CRT scanline overlay
                CRTScanlineOverlay(theme: theme, opacity: theme.scanlineIntensity)

                // Layer 3: Subtle backdrop grid
                DashboardBackdropGrid(theme: theme)

                // Layer 4: Fixed 3-pane tiled layout
                VStack(spacing: 0) {
                    TopTerminalPane(theme: theme)
                        .frame(height: size.height * 0.44)
                        .padding(.horizontal, 8)
                        .padding(.top, 8)

                    HStack(spacing: 0) {
                        BottomLeftPane(theme: theme)
                        BottomRightPane(theme: theme)
                    }
                    .frame(height: size.height * 0.54)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
                }

                // Theme cycle button (top-right corner)
                Button {
                    store.cycleTheme()
                } label: {
                    Text("[ \(store.activeTheme.name.uppercased()) ]")
                        .font(.system(.caption2, design: .monospaced).weight(.bold))
                        .foregroundStyle(theme.accent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(theme.surface.opacity(0.80))
                        .overlay(
                            Rectangle()
                                .strokeBorder(theme.primary.opacity(0.25), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .padding(.trailing, 16)
                .padding(.top, 16)
            }
        }
        .ignoresSafeArea(edges: .top)
    }
}

// MARK: - CRT Scanline Overlay

/// Full-canvas CRT scanline effect — alternating 1px dark lines at 4px spacing.
/// All lines are batched into a single Path for one GPU draw call.
private struct CRTScanlineOverlay: View {
    let theme: DashboardTheme
    let opacity: Double

    var body: some View {
        Canvas { context, size in
            let color = theme.background.opacity(opacity)
            var lines = Path()
            var y: CGFloat = 0
            while y < size.height {
                lines.addRect(CGRect(x: 0, y: y, width: size.width, height: 1))
                y += 4
            }
            context.fill(lines, with: .color(color))
        }
        .allowsHitTesting(false)
        .drawingGroup()
    }
}

// MARK: - Dashboard Backdrop Grid

struct DashboardBackdropGrid: View {
    let theme: DashboardTheme

    var body: some View {
        Canvas { context, size in
            let columns = 12
            let rows = 8
            let columnStep = size.width / CGFloat(columns)
            let rowStep = size.height / CGFloat(rows)

            var verticals = Path()
            for column in 0...columns {
                let x = CGFloat(column) * columnStep
                verticals.move(to: CGPoint(x: x, y: 0))
                verticals.addLine(to: CGPoint(x: x, y: size.height))
            }
            context.stroke(verticals, with: .color(theme.primary.opacity(0.04)), lineWidth: 1)

            var horizontals = Path()
            for row in 0...rows {
                let y = CGFloat(row) * rowStep
                horizontals.move(to: CGPoint(x: 0, y: y))
                horizontals.addLine(to: CGPoint(x: size.width, y: y))
            }
            context.stroke(horizontals, with: .color(theme.primary.opacity(0.03)), lineWidth: 1)

            var accent = Path()
            let scanlineY = size.height * 0.33
            accent.move(to: CGPoint(x: 0, y: scanlineY))
            accent.addLine(to: CGPoint(x: size.width, y: scanlineY))
            context.stroke(accent, with: .color(theme.accent.opacity(0.10)), lineWidth: 2)
        }
        .allowsHitTesting(false)
        .opacity(1)
        .drawingGroup()
    }
}
