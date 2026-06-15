import SwiftUI

struct CPUUsageSimulatorWidget: DashboardWidget {
    struct Configuration: Codable, Hashable {
        var coreCount: Int = 8
        var spikeIntensity: Double = 0.9
    }

    static let metadata = WidgetMetadata(
        id: "cpu-usage-simulator",
        name: "CPU Usage Simulator",
        description: "Fake core utilization bars with pulsing spikes and a heat gauge.",
        category: .telemetry,
        iconSystemName: "cpu",
        defaultSize: .standard,
        supportedPresentationModes: [.tiled, .floating]
    )

    static let defaultConfiguration = Configuration()

    static func makeView(configuration: Configuration, context: WidgetContext) -> AnyView {
        AnyView(CPUUsageSimulatorWidgetView(configuration: configuration, theme: context.theme))
    }

    static func makeSettingsView(configuration: Binding<Configuration>) -> AnyView {
        AnyView(CPUUsageSimulatorSettingsView(configuration: configuration))
    }
}

private struct CPUUsageSimulatorWidgetView: View {
    let configuration: CPUUsageSimulatorWidget.Configuration
    let theme: DashboardTheme

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.12, paused: false)) { timeline in
            let phase = timeline.date.timeIntervalSinceReferenceDate
            let cores = max(4, configuration.coreCount)
            let values = waveformValues(count: cores, phase: phase * 2.2, seed: 0.8, amplitude: configuration.spikeIntensity)
            let lines = cpuAsciiLines(values: values)

            VStack(alignment: .leading, spacing: 8) {
                Text("CPU LOAD")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(theme.accent)

                Text(lines.joined(separator: "\n"))
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(theme.primary)
                    .lineSpacing(2)
            }
        }
    }

    private func cpuAsciiLines(values: [Double]) -> [String] {
        var lines = ["CORE  LOAD"]
        for (index, value) in values.enumerated() {
            lines.append("C\(String(format: "%02d", index + 1)) \(asciiBar(level: value, width: 18)) \(Int(value * 100))%")
        }
        let average = values.reduce(0, +) / Double(max(values.count, 1))
        lines.append("AVG \(asciiMeter(level: average, width: 18)) \(Int(average * 100))%")
        return lines
    }
}

private struct CPUUsageSimulatorSettingsView: View {
    @Binding var configuration: CPUUsageSimulatorWidget.Configuration

    var body: some View {
        Form {
            Stepper("Cores: \(configuration.coreCount)", value: $configuration.coreCount, in: 4...32)
            Slider(value: $configuration.spikeIntensity, in: 0.4...1.4, step: 0.05) {
                Text("Spike Intensity")
            }
        }
    }
}
