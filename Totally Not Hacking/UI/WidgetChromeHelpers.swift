import SwiftUI

extension View {
    func dashboardPanelStyle(theme: DashboardTheme) -> some View {
        self
            .padding(14)
            .background(theme.surface.opacity(0.85))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(theme.primary.opacity(0.25), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

