import SwiftUI

// MARK: - Top Terminal Pane

struct TopTerminalPane: View {
    let theme: DashboardTheme

    private static let breachTrackCount = 7
    private static let chatterDisplayLimit = 9

    var body: some View {
        PaneFrame(header: "MAINFRAME BREACH // SYS.OVERRIDE", theme: theme) {
            TimelineView(.animation(minimumInterval: 0.12, paused: false)) { timeline in
                let phase = timeline.date.timeIntervalSinceReferenceDate
                GeometryReader { proxy in
                    let availableWidth = proxy.size.width

                    VStack(alignment: .leading, spacing: 4) {
                        statusLines(phase: phase)
                        Rectangle().fill(theme.primary.opacity(0.18)).frame(height: 1)
                        breachTracksView(phase: phase, width: availableWidth)
                        Rectangle().fill(theme.primary.opacity(0.18)).frame(height: 1)
                        chatterView(phase: phase)
                    }
                }
            }
        }
    }

    private func statusLines(phase: Double) -> some View {
        let loads = simulatedLoadAverages(phase: phase)
        let mem = 0.45 + 0.25 * sin(phase * 0.7)
        let threads = 180 + Int(sin(phase * 0.5) * 40)

        let loadStr = "\(fmt2(loads.0))  \(fmt2(loads.1))  \(fmt2(loads.2))"
        return VStack(alignment: .leading, spacing: 2) {
            Text("load avg: \(loadStr)")
            HStack(spacing: 4) {
                Text("mem  \(tuiBar(level: mem, width: 24))")
                Text("\(Int(mem * 100))%")
                    .foregroundStyle(mem > 0.7 ? theme.accent : theme.primary)
            }
            Text("tasks: \(threads) running  ■  ciphers: \(8 + Int(phase) % 5) active  ■  uplink: \(98 + Int(phase * 3) % 3).\(Int(phase * 17) % 10) GB/s")
        }
        .font(.system(.caption2, design: .monospaced))
        .foregroundStyle(theme.primary)
    }

    private func breachTracksView(phase: Double, width: CGFloat) -> some View {
        let tracks = breachTracks(phase: phase, count: Self.breachTrackCount)
        let barWidth = max(8, Int(width / 14))

        return VStack(alignment: .leading, spacing: 3) {
            ForEach(0..<tracks.count, id: \.self) { i in
                let t = tracks[i]
                HStack(spacing: 6) {
                    Text(t.label)
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(theme.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)

                    Text(tuiBar(level: t.progress, width: barWidth))
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(theme.primary)

                    Text("\(Int(t.progress * 100))%")
                        .font(.system(.caption2, design: .monospaced).weight(.bold))
                        .frame(width: 36, alignment: .trailing)
                        .foregroundStyle(t.progress < 0.35 ? .red : t.progress < 0.70 ? theme.accent : theme.primary)
                }
            }
        }
    }

    private func chatterView(phase: Double) -> some View {
        let lines = chatterLines(phase: phase)
        return VStack(alignment: .leading, spacing: 2) {
            ForEach(0..<min(lines.count, Self.chatterDisplayLimit), id: \.self) { i in
                Text(lines[i])
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(i % 3 == 0 ? theme.accent : theme.primary.opacity(0.85))
                    .lineLimit(1)
            }
        }
    }
}

// MARK: - Top Pane Data Generators

func fmt2(_ value: Double) -> String {
    let i = Int(value * 100 + 0.5)
    let whole = i / 100
    let frac = i % 100
    return "\(whole).\(frac < 10 ? "0" : "")\(frac)"
}

func simulatedLoadAverages(phase: Double) -> (Double, Double, Double) {
    let one = 0.8 + sin(phase * 0.4) * 0.6 + cos(phase * 0.73) * 0.3
    let five = 0.7 + sin(phase * 0.35 + 1) * 0.5
    let fifteen = 0.65 + cos(phase * 0.28 + 2) * 0.4
    return (max(0.1, one), max(0.1, five), max(0.1, fifteen))
}

func breachTracks(phase: Double, count: Int) -> [(label: String, progress: Double)] {
    let labels = [
        "BREACHING OUTER FIREWALL LAYER",
        "INJECTING ROOTKIT PAYLOAD V2.3",
        "SPOOFING CREDENTIAL TOKEN CHAIN",
        "EXFILTRATING ENCRYPTED DATABASE",
        "ROUTING THROUGH PROXY NEST #7",
        "ESCALATING KERNEL PRIVILEGES",
        "OVERWRITING SECURITY LOG TRACE",
        "DECRYPTING MASTER KEY VAULT",
        "SYNTHESIZING BACKDOOR ACCESS",
        "ERASING INTRUSION FOOTPRINT",
    ]
    return (0..<count).map { i in
        let p = 0.15 + 0.70 * abs(sin(phase * (0.6 + Double(i) * 0.11) + Double(i) * 1.7))
        return (labels[i % labels.count], min(p, 0.97))
    }
}

func chatterLines(phase: Double) -> [String] {
    let verbs = ["PATCH", "SYNC", "TRACE", "ROUTE", "SPAWN", "RENDER", "PULSE", "CACHE", "FLUSH", "INJECT", "PROBE", "SWEEP"]
    let nouns = ["cipher", "packet", "node", "relay", "matrix", "ghost", "vector", "beacon", "shard", "kernel"]
    let sectors = ["ALPHA", "BRAVO", "DELTA", "ECHO", "GAMMA", "KILO", "NOVA", "OMEGA", "SIGMA", "ZETA"]
    let actions = ["RESYNTHESIZING COHERENCE GRID", "CALIBRATING SIGNAL PATH",
                   "DISPATCHING GHOST RELAY", "CONVERGING NEURAL MESH",
                   "ESCALATING PAYLOAD DEPTH", "OBFUSCATING ORIGIN TRACE",
                   "HARDENING TUNNEL ENDPOINT", "RECALCULATING ROUTE TABLE",
                   "FLUSHING COMPROMISED CACHE", "TRIPWIRE DETECTED — SKIPPING"]

    return (0..<12).map { i in
        let h = (Int(phase) + i * 7) % 24
        let m = (Int(phase * 3) + i * 13) % 60
        let s = (Int(phase * 11) + i * 19) % 60
        let verb = verbs[(i + Int(phase)) % verbs.count]
        let noun = nouns[(i * 3 + Int(phase)) % nouns.count]
        let sector = sectors[(i * 5 + Int(phase * 2)) % sectors.count]
        let action = actions[(i * 7 + Int(phase * 3)) % actions.count]
        let delta = 12 + Int(phase * 17 + Double(i) * 23) % 89
        let crcVal = (Int(phase * 9973) + i * 7919) & 0xFFFF
        return "[\(pad2(h)):\(pad2(m)):\(pad2(s))] \(verb) \(noun) @SECTOR-\(sector) :: \(action) // DELTA \(delta)% // CRC \(pad4Hex(crcVal))"
    }
}

func pad2(_ value: Int) -> String {
    value < 10 ? "0\(value)" : "\(value)"
}

func pad4Hex(_ value: Int) -> String {
    let h = (value >> 8) & 0xFF
    let l = value & 0xFF
    return "\(hexNibble(h >> 4))\(hexNibble(h & 0xF))\(hexNibble(l >> 4))\(hexNibble(l & 0xF))"
}

func hexNibble(_ n: Int) -> String {
    n < 10 ? "\(n)" : String(Character(UnicodeScalar(65 + n - 10)!))
}
