import Foundation
import SwiftUI

func matrixGlyph(at index: Int, phase: Int) -> String {
    let glyphs: [String] = [
        "ア", "カ", "サ", "タ", "ナ", "ハ", "マ", "ヤ", "ラ", "ワ",
        "ガ", "ダ", "バ", "パ", "ギ", "ビ", "ピ", "ブ", "グ", "ズ",
        "で", "ぱ", "ポ", "ミ", "ゅ", "ょ", "ル", "ザ", "ヂ", "ゼ",
        "ゾ", "ヴ", "ヲ", "ヶ", "ぁ", "シ", "ェ", "ュ", "た", "ち",
        "つ", "て", "と", "な", "に", "ぬ", "は", "ひ", "ふ", "へ",
        "ジ", "あ", "い", "う", "え", "お", "か", "き", "く", "け",
        ":=", "|>", "<|", "/>", "\\\\", "::", "++", "--", "&&", "||",
        "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
        "@", "#", "$", "%", "&", "*", "+", "=", "~", "^",
    ]
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
