import SwiftUI

struct CPUUsageSimulatorWidget: DashboardWidget {
    struct Configuration: Codable, Hashable {
        var coreCount: Int = 8
        var spikeIntensity: Double = 0.9
        var processCount: Int = 12
        var threadCount: Int = 4
    }

    static let metadata = WidgetMetadata(
        id: "cpu-usage-simulator",
        name: "CPU Usage Simulator",
        description: "Fake core utilization bars with pulsing spikes and a heat gauge.",
        category: .telemetry,
        iconSystemName: "cpu",
        defaultSize: .standard,
        supportedPresentationModes: [.tiled, .floating]
    )

    static let defaultConfiguration = Configuration()

    static func makeView(configuration: Configuration, context: WidgetContext) -> AnyView {
        AnyView(CPUUsageSimulatorWidgetView(configuration: configuration, theme: context.theme))
    }

    static func makeSettingsView(configuration: Binding<Configuration>) -> AnyView {
        AnyView(CPUUsageSimulatorSettingsView(configuration: configuration))
    }
}

private struct CPUUsageSimulatorWidgetView: View {
    let configuration: CPUUsageSimulatorWidget.Configuration
    let theme: DashboardTheme

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.12, paused: false)) { timeline in
            let phase = timeline.date.timeIntervalSinceReferenceDate
            let cores = max(4, configuration.coreCount)
            let cpuValues = waveformValues(count: cores, phase: phase * 2.2, seed: 0.8, amplitude: configuration.spikeIntensity)
            let processes = simulatedProcesses(phase: phase, count: max(6, configuration.processCount), cores: cores)
            let loadAverages = simulatedLoadAverages(values: cpuValues, phase: phase)
            let memoryPressure = simulatedMemoryPressure(processes: processes, phase: phase)
            let threads = simulatedThreads(phase: phase, count: max(2, configuration.threadCount))

            VStack(alignment: .leading, spacing: 6) {
                Text("CPU LOAD")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(theme.accent)

                Text(cpuAsciiHeader(cpuValues: cpuValues, loadAverages: loadAverages, memoryPressure: memoryPressure, threads: threads))
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(theme.primary)

                Text(cpuAsciiProcessTable(processes: processes))
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(theme.primary)
                    .lineSpacing(1)
            }
        }
    }

    private func cpuAsciiHeader(cpuValues: [Double], loadAverages: (Double, Double, Double), memoryPressure: Double, threads: Int) -> String {
        let loadLine = String(format: "load avg: %.2f %.2f %.2f", loadAverages.0, loadAverages.1, loadAverages.2)
        let memoryLine = "mem: \(asciiBar(level: memoryPressure, width: 18)) \(Int(memoryPressure * 100))%"
        let coreLines = cpuValues.enumerated().map { index, value in
            "C\(String(format: "%02d", index + 1)) \(asciiBar(level: value, width: 14)) \(Int(value * 100))%"
        }

        var lines = [
            "PID USER     PRI  NI  VIRT   RES   SHR S  CPU%  MEM%  TIME+  COMMAND",
            "--------------------------------------------------------------------",
            loadLine,
            memoryLine,
            "threads: \(threads)  \(String(repeating: "|", count: min(threads, 12)))",
            "--------------------------------------------------------------------"
        ]

        lines.append(contentsOf: coreLines)
        return lines.joined(separator: "\n")
    }

    private func cpuAsciiProcessTable(processes: [FakeProcess]) -> String {
        processes.map { process in
            let cpu = String(format: "%5.1f", process.cpu * 100)
            let mem = String(format: "%5.1f", process.mem * 100)
            let virt = String(format: "%5.1f", process.virtGB)
            let res = String(format: "%5.1f", process.resGB)
            let shr = String(format: "%5.1f", process.shrGB)
            let time = String(format: "%02d:%02d.%02d", process.timeMinutes, process.timeSeconds, process.timeCentis)
            return [
                String(format: "%5d", process.pid),
                padRight(process.user, to: 8),
                String(format: "%3d", process.priority),
                String(format: "%3d", process.niceness),
                padLeft(virt, to: 5),
                padLeft(res, to: 5),
                padLeft(shr, to: 5),
                process.state,
                padLeft(cpu, to: 5),
                padLeft(mem, to: 5),
                padLeft(time, to: 6),
                process.command
            ]
            .joined(separator: " ")
        }
        .joined(separator: "\n")
    }

    private func padLeft(_ value: String, to width: Int) -> String {
        if value.count >= width { return value }
        return String(repeating: " ", count: width - value.count) + value
    }

    private func padRight(_ value: String, to width: Int) -> String {
        if value.count >= width { return value }
        return value + String(repeating: " ", count: width - value.count)
    }

    private func simulatedLoadAverages(values: [Double], phase: Double) -> (Double, Double, Double) {
        let average = values.reduce(0, +) / Double(max(values.count, 1))
        let one = max(0.01, average * 1.2)
        let five = max(0.01, average * 0.85 + sin(phase * 0.4) * 0.08)
        let fifteen = max(0.01, average * 0.62 + cos(phase * 0.2) * 0.05)
        return (one, five, fifteen)
    }

    private func simulatedMemoryPressure(processes: [FakeProcess], phase: Double) -> Double {
        let total = processes.map(\.mem).reduce(0, +) / Double(max(processes.count, 1))
        return min(max(total + (sin(phase * 0.5) + 1) * 0.07, 0), 1)
    }

    private func simulatedThreads(phase: Double, count: Int) -> Int {
        max(count, Int(6 + (sin(phase * 0.8) + 1) * 5))
    }

    private func simulatedProcesses(phase: Double, count: Int, cores: Int) -> [FakeProcess] {
        let names = [
            "kernel_task", "WindowServer", "launchd", "Dock", "mds", "Finder",
            "Safari", "swift-frontend", "WindowManager", "syncthing", "Music", "Spotlight"
        ]
        let users = ["root", "jimmy", "_windowserver", "mobile", "daemon"]

        return (0..<count).map { index in
            let base = Double(index)
            let cpu = min(max((sin(phase * 1.3 + base * 0.7) + 1) / 2 * configuration.spikeIntensity, 0.03), 1.0)
            let mem = min(max((cos(phase * 0.8 + base * 0.5) + 1) / 2 * 0.45 + 0.1, 0.02), 0.98)
            let virtGB = 0.4 + Double(index % 6) * 0.85 + cpu * 1.6
            let resGB = 0.2 + mem * 1.8
            let shrGB = 0.05 + Double((index + cores) % 4) * 0.18
            let priority = Int(20 + (index * 7 + Int(phase)) % 80)
            let niceness = Int((index + Int(phase * 2)) % 20) - 10
            let stateCycle = ["R", "S", "D", "I"]
            let state = stateCycle[(index + Int(phase)) % stateCycle.count]
            let command = names[(index + Int(phase)) % names.count]
            let user = users[(index * 3 + Int(phase)) % users.count]
            let pid = 100 + index * 13 + Int(phase.truncatingRemainder(dividingBy: 50))

            return FakeProcess(
                pid: pid,
                user: user,
                priority: priority,
                niceness: niceness,
                virtGB: virtGB,
                resGB: resGB,
                shrGB: shrGB,
                state: state,
                cpu: cpu,
                mem: mem,
                timeMinutes: Int((phase + base) / 5) % 60,
                timeSeconds: Int((phase * 3 + base * 11).truncatingRemainder(dividingBy: 60)),
                timeCentis: Int((phase * 100 + base * 19).truncatingRemainder(dividingBy: 100)),
                command: command
            )
        }
        .sorted { $0.cpu > $1.cpu }
    }
}

private struct FakeProcess {
    let pid: Int
    let user: String
    let priority: Int
    let niceness: Int
    let virtGB: Double
    let resGB: Double
    let shrGB: Double
    let state: String
    let cpu: Double
    let mem: Double
    let timeMinutes: Int
    let timeSeconds: Int
    let timeCentis: Int
    let command: String
}

private struct CPUUsageSimulatorSettingsView: View {
    @Binding var configuration: CPUUsageSimulatorWidget.Configuration

    var body: some View {
        Form {
            Stepper("Cores: \(configuration.coreCount)", value: $configuration.coreCount, in: 4...32)
            Slider(value: $configuration.spikeIntensity, in: 0.4...1.4, step: 0.05) {
                Text("Spike Intensity")
            }
        }
    }
}
