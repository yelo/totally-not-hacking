import SwiftUI

struct MatrixRainWidget: DashboardWidget {
    struct Configuration: Codable, Hashable {
        var columns: Int = 22
        var speed: Double = 1.0
        var brightness: Double = 0.85
    }

    static let metadata = WidgetMetadata(
        id: "matrix-rain",
        name: "Matrix Rain",
        description: "Streaming glyph rain for a cinematic backdrop.",
        category: .background,
        iconSystemName: "cloud.moon.fill",
        defaultSize: .background,
        supportedPresentationModes: [.background, .floating, .tiled]
    )

    static let defaultConfiguration = Configuration()

    static func makeView(configuration: Configuration, context: WidgetContext) -> AnyView {
        AnyView(MatrixRainWidgetView(configuration: configuration, theme: context.theme))
    }

    static func makeSettingsView(configuration: Binding<Configuration>) -> AnyView {
        AnyView(MatrixRainSettingsView(configuration: configuration))
    }
}

private struct MatrixRainWidgetView: View {
    let configuration: MatrixRainWidget.Configuration
    let theme: DashboardTheme

    var body: some View {
        GeometryReader { proxy in
            TimelineView(.animation(minimumInterval: 0.08, paused: false)) { timeline in
                let phase = Int(timeline.date.timeIntervalSinceReferenceDate * configuration.speed)
                let columns = max(configuration.columns, Int(proxy.size.width / 12))
                let rows = max(18, Int(proxy.size.height / 14))
                let lines = matrixLines(columns: columns, rows: rows, phase: phase)

                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                        Text(line)
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundStyle(index % 2 == 0 ? theme.primary : theme.accent)
                    }
                }
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topLeading)
                .background(theme.background.opacity(0.65))
            }
        }
    }

    private func matrixLines(columns: Int, rows: Int, phase: Int) -> [AttributedString] {
        (0..<rows).map { row in
            var line = AttributedString()
            for column in 0..<columns {
                let glyph = matrixGlyph(at: row * columns + column, phase: phase)
                let isHead = (row + column + phase) % 11 == 0
                var piece = AttributedString(glyph)
                piece.foregroundColor = isHead ? theme.accent : theme.primary
                line += piece

                var spacer = AttributedString(" ")
                spacer.foregroundColor = theme.primary
                line += spacer
            }
            return line
        }
    }
}

private struct MatrixRainSettingsView: View {
    @Binding var configuration: MatrixRainWidget.Configuration

    var body: some View {
        Form {
            Stepper("Columns: \(configuration.columns)", value: $configuration.columns, in: 8...40)
            Slider(value: $configuration.speed, in: 0.5...3.0, step: 0.1) {
                Text("Speed")
            }
            Slider(value: $configuration.brightness, in: 0.1...1.0, step: 0.05) {
                Text("Brightness")
            }
        }
    }
}
