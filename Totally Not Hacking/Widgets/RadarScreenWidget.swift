import SwiftUI

struct RadarScreenWidget: DashboardWidget {
    struct Configuration: Codable, Hashable {
        var blipCount: Int = 8
        var sweepSpeed: Double = 1.0
    }

    static let metadata = WidgetMetadata(
        id: "radar-screen",
        name: "Radar Screen",
        description: "Circular sweep with simulated contacts and bursts.",
        category: .telemetry,
        iconSystemName: "dot.radiowaves.left.and.right",
        defaultSize: .standard,
        supportedPresentationModes: [.tiled, .floating]
    )

    static let defaultConfiguration = Configuration()

    static func makeView(configuration: Configuration, context: WidgetContext) -> AnyView {
        AnyView(RadarScreenWidgetView(configuration: configuration, theme: context.theme))
    }
}

private struct RadarScreenWidgetView: View {
    let configuration: RadarScreenWidget.Configuration
    let theme: DashboardTheme

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.05, paused: false)) { timeline in
            let phase = timeline.date.timeIntervalSinceReferenceDate * configuration.sweepSpeed
            let display = radarAsciiGrid(phase: phase)

            VStack(alignment: .leading, spacing: 6) {
                Text("RADAR")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(theme.accent)

                Text(display.joined(separator: "\n"))
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(theme.primary)
                    .lineSpacing(1)
            }
        }
    }

    private func radarAsciiGrid(phase: Double) -> [String] {
        let size = 17
        let center = Double(size / 2)
        let radius = 7.0
        let sweepAngle = phase.truncatingRemainder(dividingBy: 1.0) * .pi * 2
        let sweepPoint = CGPoint(
            x: center + cos(sweepAngle) * radius,
            y: center + sin(sweepAngle) * radius
        )
        let blips = max(4, configuration.blipCount)
        let blipPoints: [CGPoint] = (0..<blips).map { index in
            let angle = Double(index) / Double(blips) * .pi * 2 + phase * 0.7
            let ring = 0.35 + 0.55 * abs(sin(phase * 0.8 + Double(index)))
            return CGPoint(
                x: center + cos(angle) * radius * ring,
                y: center + sin(angle) * radius * ring
            )
        }

        return (0..<size).map { row in
            let characters = (0..<size).map { column -> Character in
                let dx = Double(column) - center
                let dy = Double(row) - center
                let distance = sqrt(dx * dx + dy * dy)

                if abs(Double(column) - sweepPoint.x) < 0.55 && abs(Double(row) - sweepPoint.y) < 0.55 {
                    return ">"
                }

                if blipPoints.contains(where: { abs($0.x - Double(column)) < 0.45 && abs($0.y - Double(row)) < 0.45 }) {
                    return "*"
                }

                if abs(distance - radius) < 0.35 {
                    return "o"
                }

                if column == Int(center) || row == Int(center) {
                    return "."
                }

                return " "
            }

            return characters.map(String.init).joined(separator: " ")
        }
    }
}
