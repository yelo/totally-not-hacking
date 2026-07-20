import SwiftUI

struct BottomLeftPane: View {
    let theme: DashboardTheme

    private static let codeRowCount = 60

    var body: some View {
        PaneFrame(header: "PSEUDO CODE STREAM // LIVE", theme: theme) {
            TimelineView(.periodic(from: .now, by: 0.12)) { timeline in
                let phase = Int(timeline.date.timeIntervalSinceReferenceDate * 5)
                ScrollViewReader { scrollProxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 3) {
                            ForEach(0..<Self.codeRowCount, id: \.self) { i in
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
                    .onChange(of: phase) { oldPhase, newPhase in
                        if oldPhase != newPhase {
                            scrollProxy.scrollTo(Self.codeRowCount - 1, anchor: .bottom)
                        }
                    }
                }
            }
        }
    }
}

func codeLine(index: Int, phase: Int) -> String {
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
    case 1:  return "\(indent)let \(vr) = xor(routeTable, salt: 0x\(pad2Hex(num)), tag: \"\(tag)\")"
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

func pad2Hex(_ value: Int) -> String {
    let v = value & 0xFF
    return "\(hexNibble(v >> 4))\(hexNibble(v & 0xF))"
}

func lineColor(index: Int, theme: DashboardTheme) -> Color {
    switch index {
    case 0: theme.accent
    case 1: theme.secondary
    default: theme.primary.opacity(0.85)
    }
}
