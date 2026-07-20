import SwiftUI

struct PaneFrame<Content: View>: View {
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
