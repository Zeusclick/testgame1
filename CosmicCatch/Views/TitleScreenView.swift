import SwiftUI

struct TitleScreenView: View {
    var onStart: () -> Void
    var onSettings: () -> Void
    var onCodex: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.black, Color.indigo.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            starfieldLayer
            content
                .padding(32)
        }
    }

    private var content: some View {
        VStack(spacing: 32) {
            Spacer()
            VStack(spacing: 8) {
                Text("COSMIC")
                    .font(.system(size: 56, weight: .black, design: .rounded))
                    .tracking(8)
                Text("CATCH")
                    .font(.system(size: 56, weight: .black, design: .rounded))
                    .foregroundStyle(.purple)
                    .tracking(8)
            }
            .foregroundStyle(.white)
            .shadow(color: .purple.opacity(0.5), radius: 12)

            VStack(spacing: 18) {
                Button("Launch Mission", action: onStart)
                    .buttonStyle(PrimaryCapsuleButtonStyle())
                HStack(spacing: 16) {
                    Button("Codex", action: onCodex)
                        .buttonStyle(SecondaryCapsuleButtonStyle())
                    Button("Settings", action: onSettings)
                        .buttonStyle(SecondaryCapsuleButtonStyle())
                }
            }

            Spacer()
            Text("Swipe the horizon, catch the stars.")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.7))
        }
    }

    private var starfieldLayer: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                let starCount = 60
                for index in 0..<starCount {
                    var position = CGPoint(
                        x: CGFloat(index) / CGFloat(starCount) * size.width,
                        y: CGFloat((index * 37) % starCount) / CGFloat(starCount) * size.height
                    )
                    let offset = sin(time + Double(index)) * 12
                    position.y += CGFloat(offset)
                    let starRect = CGRect(origin: position, size: CGSize(width: 2, height: 2))
                    context.fill(
                        Path(ellipseIn: starRect),
                        with: .color(.white.opacity(0.2 + Double(index % 5) * 0.1))
                    )
                }
            }
            .allowsHitTesting(false)
        }
    }
}

struct PrimaryCapsuleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3.monospaced().weight(.bold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing),
                in: Capsule()
            )
            .foregroundStyle(.white)
            .overlay(
                Capsule()
                    .stroke(.white.opacity(configuration.isPressed ? 0.2 : 0.4), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct SecondaryCapsuleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.callout.weight(.semibold))
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(.ultraThinMaterial, in: Capsule())
            .foregroundStyle(.white)
            .overlay(
                Capsule()
                    .stroke(.white.opacity(configuration.isPressed ? 0.3 : 0.6), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    TitleScreenView(onStart: {}, onSettings: {}, onCodex: {})
        .preferredColorScheme(.dark)
}
