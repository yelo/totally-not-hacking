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
            let lines = satelliteAsciiLines(phase: phase)

            VStack(alignment: .leading, spacing: 8) {
                Text("SATELLITE TRACK")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(theme.accent)

                Text(lines.joined(separator: "\n"))
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(theme.primary)
                    .lineSpacing(2)
            }
        }
    }

    private func satelliteAsciiLines(phase: Double) -> [String] {
        let satellites = max(2, configuration.satelliteCount)
        var lines: [String] = ["ORBIT  LINK"]

        for index in 0..<satellites {
            let level = 0.45 + 0.45 * abs(sin(phase + Double(index)))
            let track = asciiBar(level: level, width: 16, filled: "=", empty: "-")
            lines.append("SAT \(String(format: "%02d", index + 1)) \(track) \(Int(level * 100))%")
        }

        lines.append("LOCK \(asciiMeter(level: (sin(phase * 0.8) + 1) / 2, width: 16))")
        return lines
    }
}
