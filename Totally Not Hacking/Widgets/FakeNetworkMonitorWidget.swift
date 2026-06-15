import SwiftUI

struct FakeNetworkMonitorWidget: DashboardWidget {
    struct Configuration: Codable, Hashable {
        var nodeCount: Int = 9
        var pulseSpeed: Double = 1.0
    }

    static let metadata = WidgetMetadata(
        id: "fake-network-monitor",
        name: "Fake Network Monitor",
        description: "Simulated graph of router activity, relays, and traffic spikes.",
        category: .telemetry,
        iconSystemName: "network",
        defaultSize: .standard,
        supportedPresentationModes: [.tiled, .floating]
    )

    static let defaultConfiguration = Configuration()

    static func makeView(configuration: Configuration, context: WidgetContext) -> AnyView {
        AnyView(FakeNetworkMonitorWidgetView(configuration: configuration, theme: context.theme))
    }

    static func makeSettingsView(configuration: Binding<Configuration>) -> AnyView {
        AnyView(FakeNetworkMonitorSettingsView(configuration: configuration))
    }
}

private struct FakeNetworkMonitorWidgetView: View {
    let configuration: FakeNetworkMonitorWidget.Configuration
    let theme: DashboardTheme

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.12, paused: false)) { timeline in
            let phase = timeline.date.timeIntervalSinceReferenceDate * configuration.pulseSpeed
            let nodes = max(4, configuration.nodeCount)
            let values = waveformValues(count: nodes, phase: phase, seed: 1.2)
            let lines = networkAsciiLines(values: values, phase: Int(phase))

            VStack(alignment: .leading, spacing: 8) {
                Text("NETWORK STATUS")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(theme.accent)

                Text(lines.joined(separator: "\n"))
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(theme.primary)
                    .lineSpacing(2)
            }
        }
    }

    private func networkAsciiLines(values: [Double], phase: Int) -> [String] {
        let average = values.reduce(0, +) / Double(max(values.count, 1))
        var lines = [
            "ROUTE   STATUS        LOAD",
            "----------------------------"
        ]

        for (index, value) in values.enumerated() {
            let node = String(format: "NODE %02d", index + 1)
            let link = asciiBar(level: value, width: 12, filled: "#", empty: "-")
            let burst = String(repeating: "*", count: (phase + index) % 3)
            lines.append("\(node) \(link) \(Int(value * 100))%\((burst.isEmpty ? "" : " \(burst)"))")
        }

        lines.append("----------------------------")
        lines.append("AVG \(asciiMeter(level: average, width: 16)) \(Int(average * 100))%")
        return lines
    }
}

private struct FakeNetworkMonitorSettingsView: View {
    @Binding var configuration: FakeNetworkMonitorWidget.Configuration

    var body: some View {
        Form {
            Stepper("Nodes: \(configuration.nodeCount)", value: $configuration.nodeCount, in: 4...18)
            Slider(value: $configuration.pulseSpeed, in: 0.5...3.0, step: 0.1) {
                Text("Pulse Speed")
            }
        }
    }
}
