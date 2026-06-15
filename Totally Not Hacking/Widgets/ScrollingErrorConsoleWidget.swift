import SwiftUI

struct ScrollingErrorConsoleWidget: DashboardWidget {
    struct Configuration: Codable, Hashable {
        var lineCount: Int = 18
        var severityBias: Double = 0.4
    }

    static let metadata = WidgetMetadata(
        id: "scrolling-error-console",
        name: "Scrolling Error Console",
        description: "Aggressive red console output with simulated failures and retries.",
        category: .diagnostics,
        iconSystemName: "exclamationmark.triangle.fill",
        defaultSize: .wide,
        supportedPresentationModes: [.tiled, .floating]
    )

    static let defaultConfiguration = Configuration()

    static func makeView(configuration: Configuration, context: WidgetContext) -> AnyView {
        AnyView(ScrollingErrorConsoleWidgetView(configuration: configuration, theme: context.theme))
    }
}

private struct ScrollingErrorConsoleWidgetView: View {
    let configuration: ScrollingErrorConsoleWidget.Configuration
    let theme: DashboardTheme

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.55)) { timeline in
            let phase = Int(timeline.date.timeIntervalSinceReferenceDate)
            let lines = (0..<configuration.lineCount).map { index -> (String, Bool) in
                let line = simulatedLogLine(prefix: "error", index: index, phase: phase)
                let severe = Double((index + phase) % 10) / 10.0 < configuration.severityBias
                return (line, severe)
            }

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(lines.enumerated()), id: \.offset) { index, entry in
                        Text(entry.0)
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundStyle(entry.1 ? theme.accent : theme.primary)
                            .shadow(color: theme.glow.opacity(entry.1 ? theme.glowIntensity : 0.3), radius: 4)
                    }
                }
            }
        }
    }
}

