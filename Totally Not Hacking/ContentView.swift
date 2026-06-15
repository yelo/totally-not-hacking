import Foundation
import SwiftUI

#Preview {
    DashboardShellView(
        store: {
            let registry = WidgetRegistry()
            DefaultWidgetCatalog.registerAll(into: registry)
            return DashboardStore(
                registry: registry,
                persistence: DashboardPersistence(fileURL: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("dashboard-preview.json"))
            )
        }()
    )
}
