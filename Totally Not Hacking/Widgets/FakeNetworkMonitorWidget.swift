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

            VStack(alignment: .leading, spacing: 12) {
                Text("NETWORK STATUS")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(theme.accent)

                Canvas { context, size in
                    let center = CGPoint(x: size.width * 0.5, y: size.height * 0.42)
                    let radius = min(size.width, size.height) * 0.32

                    for index in 0..<nodes {
                        let angle = Double(index) / Double(nodes) * .pi * 2 + phase * 0.35
                        let nodePoint = CGPoint(
                            x: center.x + cos(angle) * radius,
                            y: center.y + sin(angle) * radius * 0.72
                        )

                        var path = Path()
                        path.move(to: center)
                        path.addLine(to: nodePoint)
                        context.stroke(path, with: .color(theme.primary.opacity(0.18)), lineWidth: 1)

                        let nodeRadius = 6 + CGFloat(values[index] * 14)
                        let nodeColor = values[index] > 0.75 ? theme.accent : theme.primary
                        context.fill(Path(ellipseIn: CGRect(x: nodePoint.x - nodeRadius, y: nodePoint.y - nodeRadius, width: nodeRadius * 2, height: nodeRadius * 2)), with: .color(nodeColor))
                    }
                }

                HStack(alignment: .bottom, spacing: 6) {
                    ForEach(Array(values.enumerated()), id: \.offset) { index, value in
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(value > 0.78 ? theme.accent : theme.primary)
                                .frame(width: 10, height: max(6, CGFloat(value) * 72))
                            Text("\(index)")
                                .font(.system(.caption2, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .bottomLeading)
            }
        }
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
