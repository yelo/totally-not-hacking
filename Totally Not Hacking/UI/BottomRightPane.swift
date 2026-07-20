import SwiftUI

struct BottomRightPane: View {
    let theme: DashboardTheme

    private static let minColumns = 60
    private static let minRows = 45
    private static let cellSizeDivisor = 3.5

    var body: some View {
        PaneFrame(header: "THERMAL NOISE // DOOM FIRE", theme: theme) {
            GeometryReader { proxy in
                TimelineView(.animation(minimumInterval: 0.05, paused: false)) { timeline in
                    let phase = timeline.date.timeIntervalSinceReferenceDate
                    let cols = max(Self.minColumns, Int(proxy.size.width / Self.cellSizeDivisor))
                    let rows = max(Self.minRows, Int(proxy.size.height / Self.cellSizeDivisor))

                    Canvas { context, size in
                        let cellW = size.width / CGFloat(cols)
                        let cellH = size.height / CGFloat(rows)
                        let field = fireField(cols: cols, rows: rows, phase: phase)

                        var paths: [Int: Path] = [:]
                        for r in 0..<rows {
                            let rowOffset = r * cols
                            for c in 0..<cols {
                                let intensity = field[rowOffset + c]
                                guard intensity > 0.015 else { continue }
                                let band = fireBand(intensity)
                                let rect = CGRect(x: CGFloat(c) * cellW, y: CGFloat(r) * cellH,
                                                  width: cellW, height: cellH)
                                paths[band, default: Path()].addRect(rect)
                            }
                        }
                        for (band, path) in paths {
                            context.fill(path, with: .color(fireBandColor(band, intensity: Double(band), theme: theme)))
                        }
                    }
                }
            }
        }
    }
}
