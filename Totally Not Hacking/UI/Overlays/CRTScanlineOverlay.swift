import SwiftUI

struct CRTScanlineOverlay: View {
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
