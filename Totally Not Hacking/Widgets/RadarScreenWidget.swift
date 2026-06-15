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
            Canvas { context, size in
                let radius = min(size.width, size.height) * 0.42
                let center = CGPoint(x: size.width * 0.5, y: size.height * 0.5)

                for ring in 1...4 {
                    let ringRect = CGRect(
                        x: center.x - radius * CGFloat(ring) / 4,
                        y: center.y - radius * CGFloat(ring) / 4,
                        width: radius * 2 * CGFloat(ring) / 4,
                        height: radius * 2 * CGFloat(ring) / 4
                    )
                    context.stroke(Path(ellipseIn: ringRect), with: .color(theme.primary.opacity(0.15)), lineWidth: 1)
                }

                for angleIndex in 0..<12 {
                    let angle = Double(angleIndex) / 12.0 * .pi * 2
                    var path = Path()
                    path.move(to: center)
                    path.addLine(to: CGPoint(x: center.x + cos(angle) * radius, y: center.y + sin(angle) * radius))
                    context.stroke(path, with: .color(theme.primary.opacity(0.08)), lineWidth: 1)
                }

                let sweepAngle = phase.truncatingRemainder(dividingBy: 1.0) * .pi * 2
                let sweepEnd = CGPoint(x: center.x + cos(sweepAngle) * radius, y: center.y + sin(sweepAngle) * radius)
                var sweep = Path()
                sweep.move(to: center)
                sweep.addLine(to: sweepEnd)
                context.stroke(sweep, with: .color(theme.accent.opacity(0.95)), lineWidth: 2.5)

                let blips = max(4, configuration.blipCount)
                for index in 0..<blips {
                    let angle = Double(index) / Double(blips) * .pi * 2 + phase * 0.8
                    let ring = CGFloat(0.2 + 0.7 * abs(sin(phase * 0.9 + Double(index))))
                    let point = CGPoint(
                        x: center.x + cos(angle) * radius * ring,
                        y: center.y + sin(angle) * radius * ring
                    )
                    let pulse = 6 + CGFloat((sin(phase * 3.0 + Double(index)) + 1) * 5)
                    context.fill(Path(ellipseIn: CGRect(x: point.x - pulse, y: point.y - pulse, width: pulse * 2, height: pulse * 2)), with: .color(theme.primary.opacity(0.8)))
                }
            }
            .overlay(alignment: .topLeading) {
                Text("RADAR")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(theme.accent)
                    .padding(8)
            }
        }
    }
}

