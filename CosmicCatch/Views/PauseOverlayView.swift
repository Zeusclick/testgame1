import SwiftUI

struct PauseOverlayView: View {
    var onResume: () -> Void
    var onRestart: () -> Void
    var onQuit: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Paused")
                    .font(.largeTitle.weight(.bold))
                Text("You are in a calm drift. Ready to dive back in?")
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                VStack(spacing: 12) {
                    Button("Resume", action: onResume)
                        .buttonStyle(PrimaryCapsuleButtonStyle())
                    HStack(spacing: 12) {
                        Button("Restart", action: onRestart)
                            .buttonStyle(SecondaryCapsuleButtonStyle())
                        Button("Quit", action: onQuit)
                            .buttonStyle(SecondaryCapsuleButtonStyle())
                    }
                }
            }
            .padding(32)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    PauseOverlayView(onResume: {}, onRestart: {}, onQuit: {})
}
