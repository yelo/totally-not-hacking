import SwiftUI

func fireField(cols: Int, rows: Int, phase: Double) -> [Double] {
    let count = rows * cols
    var field = [Double](repeating: 0.0, count: count)

    let lastRowStart = (rows - 1) * cols
    for c in 0..<cols {
        let x = Double(c)
        let base = 0.55 + sin(x * 0.07 + phase * 0.4) * 0.25
                    + sin(x * 0.13 + phase * 0.6) * 0.15
                    + cos(x * 0.19 - phase * 0.5) * 0.10
        let flicker = sin(x * 2.3 + phase * 4.7) * 0.08 + cos(x * 3.1 + phase * 5.9) * 0.06
        field[lastRowStart + c] = min(1.0, max(0.1, base + flicker))
    }

    for r in (0..<(rows - 1)).reversed() {
        let currentRowStart = r * cols
        let nextRowStart = (r + 1) * cols
        for c in 0..<cols {
            var sum = field[nextRowStart + c]
            if c > 0 { sum += field[nextRowStart + c - 1] }
            if c < cols - 1 { sum += field[nextRowStart + c + 1] }
            let decay = 0.015 + doomDecay(row: r, col: c, phase: phase) * 0.04
            field[currentRowStart + c] = max(0, sum / 3.0 - decay)
        }
    }

    return field
}

func doomDecay(row: Int, col: Int, phase: Double) -> Double {
    let r = Double(row)
    let c = Double(col)
    let v = sin(r * 5.1 + c * 7.3 + phase * 9.1) * 0.5
          + cos(r * 3.7 - c * 11.1 + phase * 13.7) * 0.3
          + sin(c * 13.7 + r * 2.1 + phase * 17.3) * 0.2
    return abs(v)
}

func fireBand(_ intensity: Double) -> Int {
    if intensity > 0.88 { return 6 }
    if intensity > 0.72 { return 5 }
    if intensity > 0.55 { return 4 }
    if intensity > 0.38 { return 3 }
    if intensity > 0.20 { return 2 }
    if intensity > 0.06 { return 1 }
    return 0
}

func fireBandColor(_ band: Int, intensity: Double, theme: DashboardTheme) -> Color {
    switch band {
    case 6: return theme.accent.opacity(0.80)
    case 5: return theme.primary.opacity(0.58)
    case 4: return theme.accent.opacity(0.60)
    case 3: return theme.primary.opacity(0.55)
    case 2: return theme.primary.opacity(0.20)
    case 1: return theme.surface.opacity(0.08)
    default: return .clear
    }
}
