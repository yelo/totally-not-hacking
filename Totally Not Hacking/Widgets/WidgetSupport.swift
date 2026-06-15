import Foundation
import SwiftUI

func waveformValues(count: Int, phase: Double, seed: Double = 0.0, amplitude: Double = 1.0) -> [Double] {
    guard count > 0 else { return [] }
    return (0..<count).map { index in
        let t = Double(index) / Double(count)
        let wave = sin((t * 12.0) + phase + seed) * 0.55
            + cos((t * 7.0) + phase * 1.3 + seed * 0.7) * 0.25
            + 0.5
        return min(max(wave * amplitude, 0.0), 1.0)
    }
}

func simulatedLogLine(prefix: String, index: Int, phase: Int) -> String {
    let verbs = ["SYNC", "TRACE", "ROUTE", "SPAWN", "RENDER", "PULSE", "CACHE", "STREAM"]
    let nouns = ["signal", "packet", "node", "cluster", "relay", "matrix", "archive", "ghost"]
    let verb = verbs[(index + phase) % verbs.count]
    let noun = nouns[(index * 3 + phase) % nouns.count]
    let timestamp = String(format: "%02d:%02d:%02d", (phase + index) % 24, (phase * 3 + index * 7) % 60, (index * 11 + phase) % 60)
    return "[\(timestamp)] \(prefix) \(verb) \(noun) \(Int.random(in: 12...99))%"
}

func hexStream(seed: Int, rows: Int, columns: Int, phase: Int) -> [[String]] {
    let values = (0..<(rows * columns)).map { index -> String in
        let value = (seed * 97 + index * 31 + phase * 13) & 0xFF
        return String(format: "%02X", value)
    }
    return stride(from: 0, to: values.count, by: columns).map {
        Array(values[$0..<min($0 + columns, values.count)])
    }
}

func glyphStream(for value: Int) -> String {
    let glyphs = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#$%&*+=-")
    return String(glyphs[value % glyphs.count])
}

extension View {
    func glowingText(theme: DashboardTheme) -> some View {
        self
            .foregroundStyle(theme.primary)
            .shadow(color: theme.glow.opacity(theme.glowIntensity), radius: 8, x: 0, y: 0)
    }
}

