import SwiftUI

extension View {
    func dashboardPanelStyle(theme: DashboardTheme) -> some View {
        self
            .padding(10)
            .background(theme.surface.opacity(0.85))
            .overlay(
                Rectangle()
                    .strokeBorder(theme.primary.opacity(0.20), lineWidth: 1)
            )
    }
}

