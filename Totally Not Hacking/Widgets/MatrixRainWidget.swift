import SwiftUI

// MARK: - Configuration

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

// MARK: - View

struct MatrixRainWidgetView: View {
    let configuration: MatrixRainConfiguration
    let theme: DashboardTheme

    var body: some View {
        GeometryReader { proxy in
            TimelineView(.animation(minimumInterval: 0.04, paused: false)) { timeline in
                let phase = timeline.date.timeIntervalSinceReferenceDate * configuration.speed
                let columns = max(configuration.columns, Int(proxy.size.width / 12))
                let rows = max(30, Int(proxy.size.height / 14))

                Canvas { context, size in
                    let cellWidth = size.width / CGFloat(columns)
                    let cellHeight = size.height / CGFloat(rows)
                    let headFont = Font.system(size: 14, weight: .bold, design: .monospaced)
                    let tailFont = Font.system(size: 12, weight: .bold, design: .monospaced)
                    let dimFont = Font.system(size: 10, weight: .regular, design: .monospaced)

                    let totalSpan = Double(rows) + 20

                    for column in 0..<columns {
                        let colSeed = Double(column) * 127.1 + Double(column) * Double(column) * 11.3
                        let hasStream = colSeed.truncatingRemainder(dividingBy: 10) > 3

                        let speedVariation = 0.75 + abs(colSeed.truncatingRemainder(dividingBy: 0.5))
                        let colPhase = phase * speedVariation
                        let startOffset = colSeed.truncatingRemainder(dividingBy: totalSpan)
                        let rawHead = (colPhase + abs(startOffset)).truncatingRemainder(dividingBy: totalSpan)
                        let head = rawHead < 0 ? rawHead + totalSpan : rawHead
                        let tailLen = 10 + Int(abs(colSeed.truncatingRemainder(dividingBy: 12)))

                        if hasStream {
                            for t in 0...tailLen {
                                let rawPos = head - Double(t)
                                let wrappedPos = rawPos.truncatingRemainder(dividingBy: Double(rows))
                                let screenPos = wrappedPos < 0 ? wrappedPos + Double(rows) : wrappedPos
                                guard screenPos >= 0, screenPos < Double(rows) else { continue }

                                let brightness: Double
                                let glyph: String
                                if t == 0 {
                                    brightness = 1.0
                                    glyph = matrixGlyph(at: column * 3 + Int(phase * 7), phase: Int(colPhase))
                                } else if t <= 2 {
                                    brightness = 0.75
                                    glyph = matrixGlyph(at: column * 7 + t * 13 + Int(phase * 5), phase: Int(colPhase + Double(t)))
                                } else if t <= 6 {
                                    let fade = Double(t - 2) / 5
                                    brightness = 0.75 - fade * 0.40
                                    glyph = matrixGlyph(at: column * 11 + t * 17 + Int(phase * 3), phase: Int(colPhase + Double(t)))
                                } else {
                                    let fade = Double(t - 6) / Double(tailLen - 6)
                                    brightness = 0.35 - fade * 0.27
                                    glyph = matrixGlyph(at: column * 13 + t * 19 + Int(phase), phase: Int(colPhase + Double(t)))
                                }

                                let x = CGFloat(column) * cellWidth + cellWidth * 0.5
                                let y = CGFloat(screenPos) * cellHeight + cellHeight * 0.5
                                let opacity = brightness * Double(configuration.brightness)
                                let color = t <= 2 ? theme.accent.opacity(opacity) : theme.primary.opacity(opacity)
                                let font = t == 0 ? headFont : (t <= 6 ? tailFont : dimFont)

                                context.draw(
                                    Text(glyph).font(font).foregroundStyle(color),
                                    at: CGPoint(x: x, y: y)
                                )
                            }
                        } else {
                            let flickerChance = abs(colSeed.truncatingRemainder(dividingBy: 1))
                            if flickerChance > 0.82 {
                                let rng = Int(abs(colSeed + phase * 97)) % rows
                                let glyph = matrixGlyph(at: column * 19 + Int(phase * 11), phase: Int(phase))
                                let x = CGFloat(column) * cellWidth + cellWidth * 0.5
                                let y = CGFloat(rng) * cellHeight + cellHeight * 0.5
                                context.draw(
                                    Text(glyph).font(dimFont).foregroundStyle(theme.primary.opacity(0.18 * configuration.brightness)),
                                    at: CGPoint(x: x, y: y)
                                )
                            }
                        }
                    }
                }
                .background(theme.background.opacity(0.70))
            }
        }
    }
}
