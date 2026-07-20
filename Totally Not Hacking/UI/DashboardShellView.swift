import SwiftUI

struct DashboardShellView: View {
    @EnvironmentObject var store: DashboardStore

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
