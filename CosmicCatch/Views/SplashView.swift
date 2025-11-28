import SwiftUI

struct SplashView: View {
    @State private var shimmer = false

    var body: some View {
        ZStack {
            AngularGradient(
                colors: [Color.purple, Color.blue, Color.black, Color.mint.opacity(0.6)],
                center: .center
            )
            .ignoresSafeArea()

            VStack(spacing: 12) {
                Text("Cosmic Catch")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(LinearGradient(colors: [.white, .purple.opacity(0.7)], startPoint: .top, endPoint: .bottom))
                    .shadow(color: .purple.opacity(0.6), radius: 18, x: 0, y: 0)
                    .scaleEffect(shimmer ? 1.05 : 0.95)
                Text("Initializing Star Net...")
                    .font(.subheadline.monospaced())
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                shimmer = true
            }
        }
    }
}

#Preview {
    SplashView()
}
