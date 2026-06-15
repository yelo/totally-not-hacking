import SwiftUI

struct FakeSatelliteTrackerWidget: DashboardWidget {
    struct Configuration: Codable, Hashable {
        var satelliteCount: Int = 4
        var orbitSpeed: Double = 0.9
    }

    static let metadata = WidgetMetadata(
        id: "fake-satellite-tracker",
        name: "Fake Satellite Tracker",
        description: "Orbit arcs and tracked satellites with simulated ground-lock data.",
        category: .maps,
        iconSystemName: "moon.stars.fill",
        defaultSize: .standard,
        supportedPresentationModes: [.tiled, .floating]
    )

    static let defaultConfiguration = Configuration()

    static func makeView(configuration: Configuration, context: WidgetContext) -> AnyView {
        AnyView(FakeSatelliteTrackerWidgetView(configuration: configuration, theme: context.theme))
    }
}

private struct FakeSatelliteTrackerWidgetView: View {
    let configuration: FakeSatelliteTrackerWidget.Configuration
    let theme: DashboardTheme

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.05, paused: false)) { timeline in
            let phase = timeline.date.timeIntervalSinceReferenceDate * configuration.orbitSpeed

            Canvas { context, size in
                let center = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
                let orbitRadius = min(size.width, size.height) * 0.34

                context.fill(Path(ellipseIn: CGRect(x: center.x - 18, y: center.y - 18, width: 36, height: 36)), with: .color(theme.accent))

                for orbit in 1...3 {
                    let orbitRect = CGRect(
                        x: center.x - orbitRadius * CGFloat(orbit) / 3,
                        y: center.y - orbitRadius * CGFloat(orbit) / 4,
                        width: orbitRadius * 2 * CGFloat(orbit) / 3,
                        height: orbitRadius * 2 * CGFloat(orbit) / 4
                    )
                    context.stroke(Path(ellipseIn: orbitRect), with: .color(theme.primary.opacity(0.18)), lineWidth: 1)
                }

                let satellites = max(2, configuration.satelliteCount)
                for index in 0..<satellites {
                    let angle = phase + Double(index) / Double(satellites) * .pi * 2
                    let radius = orbitRadius * CGFloat(0.55 + 0.25 * sin(phase + Double(index)))
                    let point = CGPoint(
                        x: center.x + cos(angle) * radius,
                        y: center.y + sin(angle) * radius * 0.68
                    )
                    context.fill(Path(ellipseIn: CGRect(x: point.x - 5, y: point.y - 5, width: 10, height: 10)), with: .color(theme.primary))
                }

                var link = Path()
                link.move(to: CGPoint(x: 20, y: size.height - 20))
                link.addLine(to: CGPoint(x: size.width - 20, y: 20))
                context.stroke(link, with: .color(theme.accent.opacity(0.3)), lineWidth: 1)
            }
        }
    }
}
