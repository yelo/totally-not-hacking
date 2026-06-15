import SwiftUI

struct WorldActivityMapWidget: DashboardWidget {
    struct Configuration: Codable, Hashable {
        var hotspotCount: Int = 6
        var routeDensity: Double = 0.75
    }

    static let metadata = WidgetMetadata(
        id: "world-activity-map",
        name: "World Activity Map",
        description: "Global broadcast pulses and route arcs on a stylized map.",
        category: .maps,
        iconSystemName: "globe.americas.fill",
        defaultSize: .background,
        supportedPresentationModes: [.background, .floating, .tiled]
    )

    static let defaultConfiguration = Configuration()

    static func makeView(configuration: Configuration, context: WidgetContext) -> AnyView {
        AnyView(WorldActivityMapWidgetView(configuration: configuration, theme: context.theme))
    }

    static func makeSettingsView(configuration: Binding<Configuration>) -> AnyView {
        AnyView(WorldActivityMapSettingsView(configuration: configuration))
    }
}

private struct WorldActivityMapWidgetView: View {
    let configuration: WorldActivityMapWidget.Configuration
    let theme: DashboardTheme

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.08, paused: false)) { timeline in
            let phase = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                let sphere = CGRect(x: size.width * 0.12, y: size.height * 0.12, width: size.width * 0.76, height: size.height * 0.62)
                context.stroke(Path(ellipseIn: sphere), with: .color(theme.primary.opacity(0.45)), lineWidth: 2)

                for i in 1..<6 {
                    let y = sphere.minY + sphere.height * CGFloat(i) / 6.0
                    var path = Path()
                    path.move(to: CGPoint(x: sphere.minX, y: y))
                    path.addLine(to: CGPoint(x: sphere.maxX, y: y))
                    context.stroke(path, with: .color(theme.primary.opacity(0.12)), lineWidth: 1)
                }

                for i in 0..<7 {
                    let x = sphere.minX + sphere.width * CGFloat(i) / 6.0
                    var path = Path()
                    path.move(to: CGPoint(x: x, y: sphere.minY))
                    path.addLine(to: CGPoint(x: x, y: sphere.maxY))
                    context.stroke(path, with: .color(theme.primary.opacity(0.12)), lineWidth: 1)
                }

                let hotspots = max(3, configuration.hotspotCount)
                for index in 0..<hotspots {
                    let t = Double(index) / Double(hotspots)
                    let x = sphere.minX + sphere.width * CGFloat(0.15 + 0.7 * t)
                    let y = sphere.minY + sphere.height * CGFloat(0.25 + 0.45 * abs(sin(phase * 0.6 + Double(index))))
                    let pulse = 10 + CGFloat((sin(phase * 2.0 + Double(index)) + 1) * 7)
                    let routeAlpha = configuration.routeDensity * 0.4

                    var route = Path()
                    route.move(to: CGPoint(x: sphere.midX, y: sphere.midY))
                    route.addQuadCurve(
                        to: CGPoint(x: x, y: y),
                        control: CGPoint(x: x + 40, y: y - 60)
                    )
                    context.stroke(route, with: .color(theme.accent.opacity(routeAlpha)), lineWidth: 1.5)

                    context.fill(Path(ellipseIn: CGRect(x: x - pulse, y: y - pulse, width: pulse * 2, height: pulse * 2)), with: .color(theme.accent.opacity(0.8)))
                }
            }
        }
    }
}

private struct WorldActivityMapSettingsView: View {
    @Binding var configuration: WorldActivityMapWidget.Configuration

    var body: some View {
        Form {
            Stepper("Hotspots: \(configuration.hotspotCount)", value: $configuration.hotspotCount, in: 3...12)
            Slider(value: $configuration.routeDensity, in: 0.2...1.0, step: 0.05) {
                Text("Route Density")
            }
        }
    }
}

