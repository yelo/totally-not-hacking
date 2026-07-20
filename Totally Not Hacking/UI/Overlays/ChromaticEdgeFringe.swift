import SwiftUI

struct ChromaticEdgeFringe: View {
    let theme: DashboardTheme

    var body: some View {
        GeometryReader { proxy in
            let h = proxy.size.height
            let w = proxy.size.width

            ZStack {
                Rectangle()
                    .fill(.red)
                    .frame(height: 2)
                    .offset(y: -h / 2 + 1)
                    .opacity(0.04)
                    .blendMode(.screen)
                Rectangle()
                    .fill(.blue)
                    .frame(height: 2)
                    .offset(y: h / 2 - 1)
                    .opacity(0.04)
                    .blendMode(.screen)
            }
            .frame(width: w, height: h)
        }
        .allowsHitTesting(false)
    }
}
