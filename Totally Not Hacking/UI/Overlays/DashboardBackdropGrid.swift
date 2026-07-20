import SwiftUI

struct DashboardBackdropGrid: View {
    let theme: DashboardTheme

    private static let columns = 12
    private static let rows = 8
    private static let scanlineYRatio = 0.33

    var body: some View {
        Canvas { context, size in
            let columnStep = size.width / CGFloat(Self.columns)
            let rowStep = size.height / CGFloat(Self.rows)

            var verticals = Path()
            for column in 0...Self.columns {
                let x = CGFloat(column) * columnStep
                verticals.move(to: CGPoint(x: x, y: 0))
                verticals.addLine(to: CGPoint(x: x, y: size.height))
            }
            context.stroke(verticals, with: .color(theme.primary.opacity(0.04)), lineWidth: 1)

            var horizontals = Path()
            for row in 0...Self.rows {
                let y = CGFloat(row) * rowStep
                horizontals.move(to: CGPoint(x: 0, y: y))
                horizontals.addLine(to: CGPoint(x: size.width, y: y))
            }
            context.stroke(horizontals, with: .color(theme.primary.opacity(0.03)), lineWidth: 1)

            var accent = Path()
            let scanlineY = size.height * Self.scanlineYRatio
            accent.move(to: CGPoint(x: 0, y: scanlineY))
            accent.addLine(to: CGPoint(x: size.width, y: scanlineY))
            context.stroke(accent, with: .color(theme.accent.opacity(0.10)), lineWidth: 2)
        }
        .allowsHitTesting(false)
        .opacity(1)
        .drawingGroup()
    }
}
