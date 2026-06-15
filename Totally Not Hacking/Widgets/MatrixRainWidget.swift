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
            TimelineView(.animation(minimumInterval: 0.05, paused: false)) { timeline in
                let phase = timeline.date.timeIntervalSinceReferenceDate * configuration.speed
                let columns = max(configuration.columns, Int(proxy.size.width / 11))
                let rows = max(20, Int(proxy.size.height / 13))

                Canvas { context, size in
                    let cellWidth = size.width / CGFloat(columns)
                    let cellHeight = size.height / CGFloat(rows)

                    for row in 0..<rows {
                        for column in 0..<columns {
                            let yOffset = phase.truncatingRemainder(dividingBy: Double(rows))
                            let adjustedRow = Double(row) - yOffset
                            let glyphIndex = Int((Double(row) * 31 + Double(column) * 17) % 256)
                            let glyph = matrixGlyph(at: glyphIndex, phase: Int(phase))

                            let brightness: Double
                            if adjustedRow > Double(rows) - 3 && adjustedRow < Double(rows) {
                                brightness = 1.0
                            } else if adjustedRow > Double(rows) - 8 {
                                brightness = 0.6 + 0.4 * Double(adjustedRow - (Double(rows) - 8)) / 5
                            } else {
                                brightness = 0.35 + sin(phase * 2.0 + Double(column) * 0.5) * 0.1
                            }

                            let x = CGFloat(column) * cellWidth + cellWidth * 0.5
                            let y = CGFloat(adjustedRow) * cellHeight + cellHeight * 0.5
                            let glyphColor = brightness > 0.8 ? theme.accent : theme.primary
                            let fontSize: CGFloat = brightness > 0.8 ? 13 : 11
                            let glyphOpacity = brightness * Double(configuration.brightness)

                            context.draw(
                                Text(glyph)
                                    .font(.system(size: fontSize, weight: .bold, design: .monospaced))
                                    .foregroundStyle(glyphColor.opacity(glyphOpacity)),
                                at: CGPoint(x: x, y: y)
                            )
                        }
                    }
                }
                .background(theme.background.opacity(0.60))
            }
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
