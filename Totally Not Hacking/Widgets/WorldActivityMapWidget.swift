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
            let phase = Int(timeline.date.timeIntervalSinceReferenceDate)
            let lines = worldAsciiLines(phase: phase)

            VStack(alignment: .leading, spacing: 8) {
                Text("WORLD ACTIVITY MAP")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(theme.accent)

                Text(lines.joined(separator: "\n"))
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(theme.primary)
                    .lineSpacing(1)
            }
        }
    }

    private func worldAsciiLines(phase: Int) -> [String] {
        let rows = 15
        let columns = 33
        let hotspots = max(3, configuration.hotspotCount)
        let hotspotPoints: [CGPoint] = (0..<hotspots).map { index in
            let t = Double(index) / Double(hotspots)
            let x = 16 + cos(Double(phase + index) * 0.8 + t * .pi) * 10
            let y = 7 + sin(Double(phase + index) * 0.65 + t * .pi) * 4
            return CGPoint(x: x, y: y)
        }

        let landSeeds: [(CGPoint, CGSize)] = [
            (CGPoint(x: 8, y: 6), CGSize(width: 5, height: 3)),
            (CGPoint(x: 14, y: 8), CGSize(width: 4, height: 3)),
            (CGPoint(x: 22, y: 6), CGSize(width: 6, height: 3)),
            (CGPoint(x: 25, y: 10), CGSize(width: 3, height: 2))
        ]

        func isLand(x: Int, y: Int) -> Bool {
            landSeeds.contains { seed, size in
                let dx = (Double(x) - seed.x) / size.width
                let dy = (Double(y) - seed.y) / size.height
                return dx * dx + dy * dy <= 1.0
            }
        }

        return (0..<rows).map { row in
            (0..<columns).map { column -> Character in
                let dx = Double(column) - 16
                let dy = Double(row) - 7
                let globe = dx * dx / 220.0 + dy * dy / 42.0 <= 1.0

                if hotspotPoints.contains(where: { abs($0.x - Double(column)) < 0.5 && abs($0.y - Double(row)) < 0.5 }) {
                    return "*"
                }

                if !globe {
                    return " "
                }

                if row == 7 || column == 16 {
                    return "+"
                }

                if isLand(x: column, y: row) {
                    return "#"
                }

                return "."
            }
            .map(String.init)
            .joined(separator: " ")
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
