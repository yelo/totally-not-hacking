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
        TimelineView(.animation(minimumInterval: 0.05, paused: false)) { timeline in
            Canvas { context, size in
                let phase = timeline.date.timeIntervalSinceReferenceDate * configuration.speed
                let columns = max(8, configuration.columns)
                let rows = Int(max(18, size.height / 18.0))
                let columnStep = size.width / CGFloat(columns)
                let rowStep = size.height / CGFloat(rows)

                for column in 0..<columns {
                    let offset = Int(phase * 8) + column * 13
                    for row in 0..<rows {
                        let glyphIndex = offset + row * 7
                        let intensity = 1.0 - (Double(row) / Double(rows))
                        let yOffset = CGFloat((phase * 60.0).truncatingRemainder(dividingBy: rowStep * CGFloat(rows)))
                        let x = CGFloat(column) * columnStep + columnStep * 0.5
                        let y = CGFloat(row) * rowStep - yOffset
                        context.draw(
                            Text(glyphStream(for: glyphIndex))
                                .font(.system(size: max(12, rowStep), weight: .bold, design: .monospaced))
                                .foregroundStyle(theme.primary.opacity(configuration.brightness * intensity)),
                            at: CGPoint(x: x, y: y)
                        )
                    }
                }
            }
            .background(theme.background.opacity(0.35))
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

