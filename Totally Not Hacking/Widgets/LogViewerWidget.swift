import SwiftUI

struct LogViewerWidget: DashboardWidget {
    struct Configuration: Codable, Hashable {
        var lineCount: Int = 16
        var alertBias: Double = 0.25
    }

    static let metadata = WidgetMetadata(
        id: "log-viewer",
        name: "Log Viewer",
        description: "Streaming system logs with simulated events and statuses.",
        category: .logs,
        iconSystemName: "doc.text.magnifyingglass",
        defaultSize: .standard,
        supportedPresentationModes: [.tiled, .floating]
    )

    static let defaultConfiguration = Configuration()

    static func makeView(configuration: Configuration, context: WidgetContext) -> AnyView {
        AnyView(LogViewerWidgetView(configuration: configuration, theme: context.theme))
    }

    static func makeSettingsView(configuration: Binding<Configuration>) -> AnyView {
        AnyView(LogViewerSettingsView(configuration: configuration))
    }
}

private struct LogViewerWidgetView: View {
    let configuration: LogViewerWidget.Configuration
    let theme: DashboardTheme

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.75)) { timeline in
            let phase = Int(timeline.date.timeIntervalSinceReferenceDate)
            let lines = (0..<configuration.lineCount).map { index in
                simulatedLogLine(prefix: "log", index: index, phase: phase)
            }

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 5) {
                    ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                        Text(line)
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundStyle(index % 5 == 0 ? theme.accent : theme.primary)
                    }
                }
            }
        }
    }
}

private struct LogViewerSettingsView: View {
    @Binding var configuration: LogViewerWidget.Configuration

    var body: some View {
        Form {
            Stepper("Lines: \(configuration.lineCount)", value: $configuration.lineCount, in: 8...32)
            Slider(value: $configuration.alertBias, in: 0.0...1.0, step: 0.05) {
                Text("Alert Bias")
            }
        }
    }
}

