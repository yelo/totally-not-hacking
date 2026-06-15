import SwiftUI

struct TerminalStreamWidget: DashboardWidget {
    struct Configuration: Codable, Hashable {
        var lineCount: Int = 22
        var speed: Double = 1.0
    }

    static let metadata = WidgetMetadata(
        id: "terminal-stream",
        name: "Terminal Stream",
        description: "Animated command output with simulated shell activity.",
        category: .terminal,
        iconSystemName: "terminal.fill",
        defaultSize: .wide,
        supportedPresentationModes: [.tiled, .floating]
    )

    static let defaultConfiguration = Configuration()

    static func makeView(configuration: Configuration, context: WidgetContext) -> AnyView {
        AnyView(TerminalStreamWidgetView(configuration: configuration, theme: context.theme))
    }

    static func makeSettingsView(configuration: Binding<Configuration>) -> AnyView {
        AnyView(TerminalStreamSettingsView(configuration: configuration))
    }
}

private struct TerminalStreamWidgetView: View {
    let configuration: TerminalStreamWidget.Configuration
    let theme: DashboardTheme

    var body: some View {
        TimelineView(.periodic(from: .now, by: max(0.3, 1.0 / configuration.speed))) { timeline in
            let phase = Int(timeline.date.timeIntervalSinceReferenceDate * configuration.speed)
            let lines = (0..<configuration.lineCount).map { index in
                simulatedLogLine(prefix: "term", index: index, phase: phase)
            }

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                        Text(line)
                            .font(.system(.caption, design: .monospaced))
                            .lineLimit(1)
                            .foregroundStyle(index % 4 == 0 ? theme.accent : theme.primary)
                    }
                }
            }
        }
    }
}

private struct TerminalStreamSettingsView: View {
    @Binding var configuration: TerminalStreamWidget.Configuration

    var body: some View {
        Form {
            Stepper("Lines: \(configuration.lineCount)", value: $configuration.lineCount, in: 8...60)
            Slider(value: $configuration.speed, in: 0.5...3.0, step: 0.1) {
                Text("Speed")
            }
        }
    }
}

