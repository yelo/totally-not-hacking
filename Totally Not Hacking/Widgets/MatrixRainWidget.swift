import SwiftUI

struct MatrixRainConfiguration: Codable, Hashable {
    var columns: Int = 22
    var speed: Double = 1.0
    var brightness: Double = 0.85

    init(columns: Int = 22, speed: Double = 1.0, brightness: Double = 0.85) {
        self.columns = columns
        self.speed = speed
        self.brightness = brightness
    }
}

extension MatrixRainConfiguration {
    static let `default` = MatrixRainConfiguration()
}

struct MatrixRainWidgetView: View {
    let configuration: MatrixRainConfiguration
    let theme: DashboardTheme

    var body: some View {
        GeometryReader { proxy in
            TimelineView(.animation(minimumInterval: 0.04, paused: false)) { timeline in
                let phase = timeline.date.timeIntervalSinceReferenceDate * configuration.speed
                let columns = max(configuration.columns, Int(proxy.size.width / 8))
                let rows = max(30, Int(proxy.size.height / 14))

                Canvas { context, size in
                    let cellWidth = size.width / CGFloat(columns)
                    let cellHeight = size.height / CGFloat(rows)
                    let headFont = Font.system(size: 13, weight: .regular, design: .monospaced)
                    let trailFont = Font.system(size: 10, weight: .regular, design: .monospaced)
                    let totalSpan = Double(rows) + 24

                    for column in 0..<columns {
                        let colSeed = Double(column) * 127.1 + Double(column) * Double(column) * 11.3
                        let hasStream = colSeed.truncatingRemainder(dividingBy: 10) > 1.5

                        let speedVariation = 0.5 + abs(colSeed.truncatingRemainder(dividingBy: 1.0))
                        let colPhase = phase * speedVariation * 1.2
                        let startOffset = colSeed.truncatingRemainder(dividingBy: totalSpan)
                        let rawHead = (colPhase + abs(startOffset)).truncatingRemainder(dividingBy: totalSpan)
                        let head = rawHead < 0 ? rawHead + totalSpan : rawHead
                        let tailLen = 8 + Int(abs(colSeed.truncatingRemainder(dividingBy: 16)))

                        if hasStream {
                            let wobbleX = sin(phase * 19.7 + colSeed * 3.1) * 0.4
                            let headBrightness = 0.90 + abs(sin(colPhase * 2.7)) * 0.10

                            for t in 0...tailLen {
                                let rawPos = head - Double(t)
                                let wrappedPos = rawPos.truncatingRemainder(dividingBy: Double(rows))
                                let screenPos = wrappedPos < 0 ? wrappedPos + Double(rows) : wrappedPos
                                guard screenPos >= 0, screenPos < Double(rows) else { continue }

                                let glyph = matrixGlyph(at: column * 3 + t * 7 + Int(phase * 13), phase: Int(colPhase + Double(t)))
                                var brightness: Double
                                let font: Font

                                if t == 0 {
                                    brightness = headBrightness
                                    font = headFont
                                } else {
                                    let fraction = Double(t) / Double(tailLen)
                                    brightness = (1.0 - fraction * fraction) * headBrightness
                                    brightness = max(brightness, 0.04)
                                    font = trailFont
                                }

                                let x = CGFloat(column) * cellWidth + cellWidth * 0.5 + (t == 0 ? wobbleX : 0)
                                let y = CGFloat(screenPos) * cellHeight + cellHeight * 0.5
                                let opacity = brightness * Double(configuration.brightness)
                                let color = theme.primary.opacity(opacity)

                                context.draw(
                                    Text(glyph).font(font).foregroundStyle(color),
                                    at: CGPoint(x: x, y: y)
                                )
                            }
                        } else {
                            let flickerVal = abs(sin(colSeed * 73.1 + phase * 37.3))
                            if flickerVal > 0.88 {
                                let rng = Int(abs(colSeed + phase * 113)) % rows
                                let glyph = matrixGlyph(at: column * 19 + Int(phase * 11), phase: Int(phase))
                                let x = CGFloat(column) * cellWidth + cellWidth * 0.5
                                let y = CGFloat(rng) * cellHeight + cellHeight * 0.5
                                let flickerBrightness = 0.12 + abs(sin(phase * 47.1 + colSeed * 19.3)) * 0.10
                                context.draw(
                                    Text(glyph).font(trailFont).foregroundStyle(theme.primary.opacity(flickerBrightness * Double(configuration.brightness))),
                                    at: CGPoint(x: x, y: y)
                                )
                            }
                        }
                    }
                }
                .background(theme.background.opacity(0.85))
                .drawingGroup()
            }
        }
    }
}
