import SwiftUI

struct EdgeVignetteOverlay: View {
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
