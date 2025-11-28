import SwiftUI

enum CosmicStyle {
    static let background = Color.black
    static let overlayBackground = Color.black.opacity(0.65)
    static let hudMaterial = .ultraThinMaterial
    static let accent = Color.purple
    static let danger = Color.red
    static let success = Color.green
}

struct CosmicTitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 32, weight: .heavy, design: .rounded))
            .foregroundStyle(LinearGradient(colors: [.white, .purple], startPoint: .top, endPoint: .bottom))
    }
}

extension View {
    func cosmicTitle() -> some View { modifier(CosmicTitle()) }
}

struct HUDPillStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(CosmicStyle.hudMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 6)
    }
}

struct CosmicCapsuleButtonStyle: ButtonStyle {
    var fill: Color = CosmicStyle.accent
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(fill.opacity(configuration.isPressed ? 0.8 : 1), in: Capsule())
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}
