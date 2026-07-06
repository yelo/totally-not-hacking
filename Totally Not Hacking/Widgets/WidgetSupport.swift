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

func asciiBar(level: Double, width: Int, filled: Character = "#", empty: Character = "-") -> String {
    let clamped = min(max(level, 0), 1)
    let filledCount = Int((clamped * Double(width)).rounded())
    let emptyCount = max(0, width - filledCount)
    return "[" + String(repeating: String(filled), count: filledCount) + String(repeating: String(empty), count: emptyCount) + "]"
}

func asciiMeter(level: Double, width: Int, head: Character = ">") -> String {
    let clamped = min(max(level, 0), 1)
    let position = min(width - 1, max(0, Int((clamped * Double(width - 1)).rounded())))
    let left = String(repeating: ".", count: position)
    let right = String(repeating: ".", count: max(0, width - position - 1))
    return left + String(head) + right
}

func matrixGlyph(at index: Int, phase: Int) -> String {
    let glyphs = ["ア", "カ", "サ", "タ", "ナ", "ハ", "マ", "ヤ", "ラ", "ワ", "ン",
                  "ガ", "ダ", "バ", "パ", "ジ", "ギ", "ビ", "ピ", "ブ", "グ", "ズ",
                  "ぎ", "ぐ", "げ", "ご", "が", "ぎ", "ぐ", "げ", "ご", "が"]
    return glyphs[abs(index + phase) % glyphs.count]
}

extension View {
    func glowingText(theme: DashboardTheme) -> some View {
        self
            .foregroundStyle(theme.primary)
            .shadow(color: theme.glow.opacity(theme.glowIntensity), radius: 8, x: 0, y: 0)
    }

    /// Subtle 1px CRT text bloom — sharp, not soft.
    func crtGlow(theme: DashboardTheme) -> some View {
        self
            .foregroundStyle(theme.primary)
            .shadow(color: theme.primary.opacity(0.35), radius: 1, x: 0, y: 0)
    }
}

// MARK: - TUI Block-Character Helpers

/// Unicode block-element progress bar: `████░░░░`
func tuiBar(level: Double, width: Int) -> String {
    let clamped = min(max(level, 0), 1)
    let scaled = clamped * Double(width)
    let fullBlocks = min(Int(scaled), width)
    let remainder = scaled - Double(fullBlocks)
    let remainderIndex = min(Int((remainder * 8).rounded()), 7)
    let partials: [String] = ["", "▏", "▎", "▍", "▌", "▋", "▊", "▉"]

    var result = String(repeating: "█", count: fullBlocks)
    if fullBlocks < width {
        result += partials[remainderIndex]
        let used = fullBlocks + (remainderIndex > 0 ? 1 : 0)
        result += String(repeating: "░", count: width - used)
    }
    return result
}

/// Unicode block-character meter with diamond cursor: `▔▔◆▁▁`
func tuiMeter(level: Double, width: Int) -> String {
    let clamped = min(max(level, 0), 1)
    let position = min(width - 1, max(0, Int((clamped * Double(width - 1)).rounded())))
    let left = String(repeating: "▔", count: position)
    let right = String(repeating: "▁", count: max(0, width - position - 1))
    return left + "◆" + right
}

/// Repeating box-drawing divider: `══════════`
func tuiDivider(length: Int, char: Character = "═") -> String {
    String(repeating: String(char), count: max(length, 1))
}
