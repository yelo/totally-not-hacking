import Foundation

struct DashboardPersistence {
    let fileURL: URL

    static func live() throws -> DashboardPersistence {
        let fileManager = FileManager.default
        let baseURL = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent("TotallyNotHacking", isDirectory: true)

        try fileManager.createDirectory(at: baseURL, withIntermediateDirectories: true)
        return DashboardPersistence(fileURL: baseURL.appending(path: "dashboard-state.json"))
    }

    func load() throws -> DashboardState {
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode(DashboardState.self, from: data)
    }

    func save(_ state: DashboardState) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(state)
        try data.write(to: fileURL, options: [.atomic])
    }
}
