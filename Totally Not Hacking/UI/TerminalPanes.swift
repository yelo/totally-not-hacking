import SwiftUI

// MARK: - Shared Pane Chrome

/// Sharp-rectangle transparent terminal pane wrapper with a header strip.
private struct PaneFrame<Content: View>: View {
    let header: String
    let theme: DashboardTheme
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                Text("[▓]")
                    .foregroundStyle(theme.accent)
                Text(header)
                    .foregroundStyle(theme.primary)
                Spacer()
            }
            .font(.system(.caption, design: .monospaced).weight(.regular))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(theme.surface.opacity(0.75))
            .overlay(alignment: .bottom) {
                VStack(spacing: 1) {
                    Rectangle()
                        .fill(theme.primary.opacity(0.35))
                        .frame(height: 1)
                    Rectangle()
                        .fill(theme.primary.opacity(0.20))
                        .frame(height: 1)
                }
            }

            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(6)
        }
        .background(theme.surface.opacity(0.50))
        .overlay(
            Rectangle()
                .strokeBorder(theme.primary.opacity(0.35), lineWidth: 1)
        )
    }
}

// MARK: - Top Terminal Pane

struct TopTerminalPane: View {
    let theme: DashboardTheme

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

        return VStack(alignment: .leading, spacing: 2) {
            Text("load avg: \(String(format: "%.2f", loads.0))  \(String(format: "%.2f", loads.1))  \(String(format: "%.2f", loads.2))")
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
        let trackCount = 7
        let tracks = breachTracks(phase: phase, count: trackCount)
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
            ForEach(0..<min(lines.count, 9), id: \.self) { i in
                Text(lines[i])
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(i % 3 == 0 ? theme.accent : theme.primary.opacity(0.85))
                    .lineLimit(1)
            }
        }
    }
}

// MARK: - Top Pane Data Generators

private func simulatedLoadAverages(phase: Double) -> (Double, Double, Double) {
    let one = 0.8 + sin(phase * 0.4) * 0.6 + cos(phase * 0.73) * 0.3
    let five = 0.7 + sin(phase * 0.35 + 1) * 0.5
    let fifteen = 0.65 + cos(phase * 0.28 + 2) * 0.4
    return (max(0.1, one), max(0.1, five), max(0.1, fifteen))
}

private func breachTracks(phase: Double, count: Int) -> [(label: String, progress: Double)] {
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

private func chatterLines(phase: Double) -> [String] {
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
        let crc = String(format: "%04X", (Int(phase * 9973) + i * 7919) & 0xFFFF)
        return String(format: "[%02d:%02d:%02d] %@ %@ @SECTOR-%@ :: %@ // DELTA %d%% // CRC %@",
                      h, m, s, verb, noun, sector, action, delta, crc)
    }
}

// MARK: - Bottom-Left Pane (Scrolling Code)

struct BottomLeftPane: View {
    let theme: DashboardTheme

    var body: some View {
        PaneFrame(header: "PSEUDO CODE STREAM // LIVE", theme: theme) {
            TimelineView(.periodic(from: .now, by: 0.12)) { timeline in
                let phase = Int(timeline.date.timeIntervalSinceReferenceDate * 5)
                ScrollViewReader { scrollProxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 3) {
                            ForEach(0..<60, id: \.self) { i in
                                let line = codeLine(index: i, phase: phase)
                                Text(line)
                                    .font(.system(.caption2, design: .monospaced))
                                    .foregroundStyle(lineColor(index: i % 6, theme: theme))
                                    .lineLimit(1)
                                    .id(i)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                    .onChange(of: phase) { _, _ in
                        scrollProxy.scrollTo(59, anchor: .bottom)
                    }
                }
            }
        }
    }
}

private func codeLine(index: Int, phase: Int) -> String {
    let funcs = ["injectVector", "xorCipherStream", "routePayload", "syncNodeMesh",
                 "renderGhostPath", "pulseBeaconGrid", "cacheRouteTable", "flushDeadRelays",
                 "spawnShadowThread", "traceOriginHop", "probeFirewallGap", "sweepLogArtifacts"]
    let vars = ["cipherKey", "routeTable", "nodeIndex", "packetBuffer", "ghostTrace",
                "signalPath", "relayChain", "shadowMap", "gridState", "beaconID", "kernelRef", "entropyPool"]
    let ops = ["^", "|", "&", "<<", ">>", "~", "⊕", "⊗", "⊖", "⊞", "⊠", "⊡"]
    let modes = ["shadow", "stealth", "ghost", "phantom", "silent", "covert", "deep", "rapid"]
    let tags = ["VX-050", "GH-117", "NX-309", "SP-442", "KR-881", "DM-223", "CV-667", "AX-999", "QZ-001"]

    let sel = index % 12
    let indent = String(repeating: " ", count: [0, 2, 4, 2, 6, 4, 2, 0, 4, 6, 2, 4][sel])
    let fn = funcs[(sel + phase / 8) % funcs.count]
    let vr = vars[(sel * 3 + phase / 5) % vars.count]
    let op = ops[(sel + phase / 3) % ops.count]
    let mode = modes[(sel + phase / 6) % modes.count]
    let tag = tags[(sel * 2 + phase / 4) % tags.count]
    let num = (phase * 7 + index * 31) & 0xFF

    switch sel {
    case 0:  return "\(indent)func \(fn)(_ source: GridNode, mode: .\(mode)) async throws -> PulseStream {"
    case 1:  return "\(indent)let \(vr) = xor(routeTable, salt: 0x\(String(format: "%02X", num)), tag: \"\(tag)\")"
    case 2:  return "\(indent)guard \(vr).entropy > 50, !routeTable.isCompromised else { throw BreachError.cascade(\"\(tag)\") }"
    case 3:  return "\(indent)for node in \(vr).activeNodes where node.priority \(op) 3 != 0 {"
    case 4:  return "\(indent)    await node.dispatch(payload: shadowPacket, via: .\(mode))"
    case 5:  return "\(indent)if signalPath.latency < \(20 + num % 80).ms, relayChain.isHealthy {"
    case 6:  return "\(indent)  shell.exec(\"\(fn) \(vr) --tag \(tag) --mode \(mode)\")"
    case 7:  return "\(indent)switch ghostTrace.status { case .active: fallthrough; case .\(mode): break }"
    case 8:  return "\(indent)defer { Log.trace(\"\(vr) :: \(tag) :: completed\") }"
    case 9:  return "\(indent)let beacon = try await self.\(fn)(cipher: \(fn), depth: \(num))"
    case 10: return "\(indent)// \(tag) :: phase \(num % 4 + 1) complete — \(70 + num % 31)% coherence"
    case 11: return "\(indent)}"
    default: return "\(indent)}"
    }
}

private func lineColor(index: Int, theme: DashboardTheme) -> Color {
    switch index {
    case 0: theme.accent
    case 1: theme.secondary
    default: theme.primary.opacity(0.85)
    }
}

// MARK: - Bottom-Right Pane (Doom Fire)

struct BottomRightPane: View {
    let theme: DashboardTheme

    var body: some View {
        PaneFrame(header: "THERMAL NOISE // DOOM FIRE", theme: theme) {
            GeometryReader { proxy in
                TimelineView(.animation(minimumInterval: 0.05, paused: false)) { timeline in
                    let phase = timeline.date.timeIntervalSinceReferenceDate
                    let cols = max(60, Int(proxy.size.width / 3.5))
                    let rows = max(45, Int(proxy.size.height / 3.5))

                    Canvas { context, size in
                        let cellW = size.width / CGFloat(cols)
                        let cellH = size.height / CGFloat(rows)
                        let field = fireField(cols: cols, rows: rows, phase: phase)

                        // Batch rects into 7 color bands — one fill per band
                        var paths: [Int: Path] = [:]
                        for r in 0..<rows {
                            for c in 0..<cols {
                                let intensity = field[r][c]
                                guard intensity > 0.015 else { continue }
                                let band = fireBand(intensity)
                                let rect = CGRect(x: CGFloat(c) * cellW, y: CGFloat(r) * cellH,
                                                  width: cellW, height: cellH)
                                paths[band, default: Path()].addRect(rect)
                            }
                        }
                        for (band, path) in paths {
                            context.fill(path, with: .color(fireBandColor(band, intensity: Double(band), theme: theme)))
                        }
                    }
                }
            }
        }
    }
}

private func fireField(cols: Int, rows: Int, phase: Double) -> [[Double]] {
    var field = Array(repeating: Array(repeating: 0.0, count: cols), count: rows)

    // Bottom row: intense heat with organic variation — the flame source
    for c in 0..<cols {
        let x = Double(c)
        // Broad heat base with column-to-column variation
        let base = 0.55 + sin(x * 0.07 + phase * 0.4) * 0.25
                    + sin(x * 0.13 + phase * 0.6) * 0.15
                    + cos(x * 0.19 - phase * 0.5) * 0.10
        // Fast flicker per column
        let flicker = sin(x * 2.3 + phase * 4.7) * 0.08 + cos(x * 3.1 + phase * 5.9) * 0.06
        field[rows - 1][c] = min(1.0, max(0.1, base + flicker))
    }

    // Classic Doom fire propagation: average of 3 below, minus tiny decay
    for r in (0..<(rows - 1)).reversed() {
        for c in 0..<cols {
            var sum = field[r + 1][c]
            if c > 0 { sum += field[r + 1][c - 1] }
            if c < cols - 1 { sum += field[r + 1][c + 1] }
            // Tiny pseudo-random decay — drives the flicker without killing the flame
            let decay = 0.015 + doomDecay(row: r, col: c, phase: phase) * 0.04
            field[r][c] = max(0, sum / 3.0 - decay)
        }
    }

    return field
}

/// Tiny pseudo-random decay for each cell — drives flicker without visual repetition.
private func doomDecay(row: Int, col: Int, phase: Double) -> Double {
    let r = Double(row)
    let c = Double(col)
    let v = sin(r * 5.1 + c * 7.3 + phase * 9.1) * 0.5
          + cos(r * 3.7 - c * 11.1 + phase * 13.7) * 0.3
          + sin(c * 13.7 + r * 2.1 + phase * 17.3) * 0.2
    return abs(v) // always positive, 0.0–1.0 range
}

/// Bucket intensity into one of 7 bands (0 = coolest, 6 = hottest).
private func fireBand(_ intensity: Double) -> Int {
    if intensity > 0.88 { return 6 }
    if intensity > 0.72 { return 5 }
    if intensity > 0.55 { return 4 }
    if intensity > 0.38 { return 3 }
    if intensity > 0.20 { return 2 }
    if intensity > 0.06 { return 1 }
    return 0
}

private func fireBandColor(_ band: Int, intensity: Double, theme: DashboardTheme) -> Color {
    switch band {
    case 6: return Color.white.opacity(0.88)
    case 5: return Color.white.opacity(0.58)
    case 4: return theme.accent.opacity(0.60)
    case 3: return theme.primary.opacity(0.55)
    case 2: return theme.primary.opacity(0.20)
    case 1: return theme.surface.opacity(0.08)
    default: return .clear
    }
}
