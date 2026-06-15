import SwiftUI

struct DashboardTheme: Identifiable, Codable, Hashable {
    struct Palette: Codable, Hashable {
        var primaryHex: String
        var secondaryHex: String
        var accentHex: String
        var backgroundHex: String
        var surfaceHex: String
        var textHex: String
        var glowHex: String
        var glowIntensity: Double
    }

    var id: String
    var name: String
    var palette: Palette

    var primary: Color { Color(hex: palette.primaryHex) }
    var secondary: Color { Color(hex: palette.secondaryHex) }
    var accent: Color { Color(hex: palette.accentHex) }
    var background: Color { Color(hex: palette.backgroundHex) }
    var surface: Color { Color(hex: palette.surfaceHex) }
    var text: Color { Color(hex: palette.textHex) }
    var glow: Color { Color(hex: palette.glowHex) }
    var glowIntensity: Double { palette.glowIntensity }

    var headlineFont: Font { .system(.headline, design: .monospaced).weight(.semibold) }
    var bodyFont: Font { .system(.body, design: .monospaced) }
}

enum DashboardThemes {
    static let classicGreen = DashboardTheme(
        id: "classic-green-terminal",
        name: "Classic Green Terminal",
        palette: .init(
            primaryHex: "#6BFF8A",
            secondaryHex: "#9AFFB0",
            accentHex: "#C8FFD4",
            backgroundHex: "#050C08",
            surfaceHex: "#0C1A12",
            textHex: "#D7FFE0",
            glowHex: "#72FF9B",
            glowIntensity: 0.85
        )
    )

    static let amberCRT = DashboardTheme(
        id: "amber-crt",
        name: "Amber CRT",
        palette: .init(
            primaryHex: "#FFB347",
            secondaryHex: "#FFD18A",
            accentHex: "#FFE4B8",
            backgroundHex: "#120B04",
            surfaceHex: "#221404",
            textHex: "#FFE8C6",
            glowHex: "#FFB74D",
            glowIntensity: 0.75
        )
    )

    static let iceBlue = DashboardTheme(
        id: "ice-blue",
        name: "Ice Blue",
        palette: .init(
            primaryHex: "#7FD7FF",
            secondaryHex: "#B9ECFF",
            accentHex: "#E1F8FF",
            backgroundHex: "#061019",
            surfaceHex: "#0B1C2A",
            textHex: "#E9FAFF",
            glowHex: "#7EDCFF",
            glowIntensity: 0.78
        )
    )

    static let redAlert = DashboardTheme(
        id: "red-alert",
        name: "Red Alert",
        palette: .init(
            primaryHex: "#FF6B6B",
            secondaryHex: "#FF9B9B",
            accentHex: "#FFD1D1",
            backgroundHex: "#1A0404",
            surfaceHex: "#2B0A0A",
            textHex: "#FFECEC",
            glowHex: "#FF6B6B",
            glowIntensity: 0.88
        )
    )

    static let all: [DashboardTheme] = [classicGreen, amberCRT, iceBlue, redAlert]
}

extension Color {
    init(hex: String) {
        let sanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&value)

        let r, g, b, a: Double
        switch sanitized.count {
        case 6:
            r = Double((value >> 16) & 0xFF) / 255.0
            g = Double((value >> 8) & 0xFF) / 255.0
            b = Double(value & 0xFF) / 255.0
            a = 1.0
        case 8:
            r = Double((value >> 24) & 0xFF) / 255.0
            g = Double((value >> 16) & 0xFF) / 255.0
            b = Double((value >> 8) & 0xFF) / 255.0
            a = Double(value & 0xFF) / 255.0
        default:
            r = 0.0
            g = 0.0
            b = 0.0
            a = 1.0
        }

        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

