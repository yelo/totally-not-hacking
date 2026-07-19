import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: DashboardStore

    var body: some View {
        DashboardShellView(store: store)
    }
}

struct DashboardShellView: View {
    @ObservedObject var store: DashboardStore

    var body: some View {
        GeometryReader { proxy in
            let theme = store.activeTheme
            let size = proxy.size

            ZStack(alignment: .topTrailing) {
                MatrixRainWidgetView(
                    configuration: MatrixRainConfiguration(speed: 1.2, brightness: 0.75),
                    theme: theme
                )
                .ignoresSafeArea()
                .allowsHitTesting(false)

                CRTScanlineOverlay(theme: theme, opacity: theme.scanlineIntensity)
                DashboardBackdropGrid(theme: theme)
                EdgeVignetteOverlay(theme: theme)
                ChromaticEdgeFringe(theme: theme)

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

                Button {
                    store.cycleTheme()
                } label: {
                    HStack(spacing: 3) {
                        Text("◀")
                            .foregroundStyle(theme.secondary.opacity(0.7))
                        Text(store.activeTheme.name.uppercased())
                            .font(.system(.caption2, design: .monospaced).weight(.regular))
                            .foregroundStyle(theme.accent)
                        Text("▶")
                            .foregroundStyle(theme.secondary.opacity(0.7))
                    }
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(theme.surface.opacity(0.65))
                    .overlay(
                        Rectangle()
                            .strokeBorder(theme.primary.opacity(0.30), lineWidth: 1)
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

private struct CRTScanlineOverlay: View {
    let theme: DashboardTheme
    let opacity: Double

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.08, paused: false)) { timeline in
            let jitter = sin(timeline.date.timeIntervalSinceReferenceDate * 0.7) * 0.4

            Canvas { context, size in
                let color = theme.background.opacity(opacity)
                var lines = Path()
                var y: CGFloat = 0
                var row = 0
                while y < size.height {
                    let height: CGFloat = row % 2 == 0 ? 2 : 1
                    let offsetX = row % 4 == 0 ? jitter : -jitter * 0.6
                    lines.addRect(CGRect(x: offsetX, y: y, width: size.width, height: height))
                    y += 2
                    row += 1
                }
                context.fill(lines, with: .color(color))
            }
        }
        .allowsHitTesting(false)
        .drawingGroup()
    }
}

private struct EdgeVignetteOverlay: View {
    let theme: DashboardTheme

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            RadialGradient(
                gradient: Gradient(stops: [
                    .init(color: .clear, location: 0.65),
                    .init(color: theme.background.opacity(0.08), location: 0.85),
                    .init(color: theme.background.opacity(0.20), location: 1.0),
                ]),
                center: .center,
                startRadius: min(size.width, size.height) * 0.35,
                endRadius: max(size.width, size.height) * 0.75
            )
        }
        .allowsHitTesting(false)
    }
}

private struct ChromaticEdgeFringe: View {
    let theme: DashboardTheme

    var body: some View {
        GeometryReader { proxy in
            let h = proxy.size.height
            let w = proxy.size.width

            ZStack {
                Rectangle()
                    .fill(.red)
                    .frame(height: 2)
                    .offset(y: -h / 2 + 1)
                    .opacity(0.04)
                    .blendMode(.screen)
                Rectangle()
                    .fill(.blue)
                    .frame(height: 2)
                    .offset(y: h / 2 - 1)
                    .opacity(0.04)
                    .blendMode(.screen)
            }
            .frame(width: w, height: h)
        }
        .allowsHitTesting(false)
    }
}

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
