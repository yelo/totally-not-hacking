import SwiftUI

struct HexDumpViewerWidget: DashboardWidget {
    struct Configuration: Codable, Hashable {
        var rows: Int = 8
        var columns: Int = 16
        var seed: Int = 42
    }

    static let metadata = WidgetMetadata(
        id: "hex-dump-viewer",
        name: "Hex Dump Viewer",
        description: "Pseudo memory pages rendered as a diagnostic hex dump.",
        category: .diagnostics,
        iconSystemName: "tablecells",
        defaultSize: .standard,
        supportedPresentationModes: [.tiled, .floating]
    )

    static let defaultConfiguration = Configuration()

    static func makeView(configuration: Configuration, context: WidgetContext) -> AnyView {
        AnyView(HexDumpViewerWidgetView(configuration: configuration, theme: context.theme))
    }
}

private struct HexDumpViewerWidgetView: View {
    let configuration: HexDumpViewerWidget.Configuration
    let theme: DashboardTheme

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.18, paused: false)) { timeline in
            let phase = Int(timeline.date.timeIntervalSinceReferenceDate)
            let rows = max(4, configuration.rows)
            let columns = max(8, configuration.columns)
            let stream = hexStream(seed: configuration.seed, rows: rows, columns: columns, phase: phase)

            VStack(alignment: .leading, spacing: 6) {
                Text("0000: 00 01 02 03")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(theme.accent)

                ForEach(Array(stream.enumerated()), id: \.offset) { rowIndex, row in
                    HStack(spacing: 10) {
                        Text(String(format: "%04X:", rowIndex * columns))
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .frame(width: 42, alignment: .leading)
                        Text(row.joined(separator: " "))
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundStyle(theme.primary)
                    }
                }
            }
        }
    }
}

