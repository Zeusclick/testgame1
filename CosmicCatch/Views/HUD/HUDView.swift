import SwiftUI

struct HUDView: View {
    @EnvironmentObject private var hudViewModel: HUDViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                HudPill(title: "Score", value: hudViewModel.scoreText)
                HudPill(title: "Combo", value: hudViewModel.comboText)
                HudPill(title: "Lives", value: hudViewModel.livesText)
            }
            ProgressView(value: hudViewModel.missionProgress)
                .progressViewStyle(.linear)
                .tint(CosmicStyle.accent)
                .overlay(alignment: .leading) {
                    Text(hudViewModel.missionTitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 4)
                }
            PowerMeterView(power: hudViewModel.powerMeter)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }
}

enum HudPillTheme { case normal, warning }

struct HudPill: View {
    var title: String
    var value: String
    var theme: HudPillTheme = .normal

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title.uppercased())
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline.monospacedDigit())
        }
        .modifier(HUDPillStyle())
        .foregroundStyle(theme == .normal ? Color.white : CosmicStyle.danger)
    }
}

struct PowerMeterView: View {
    var power: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Power Meter")
                .font(.caption)
                .foregroundStyle(.secondary)
            GeometryReader { proxy in
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                            .frame(width: proxy.size.width * power)
                            .animation(.easeInOut(duration: 0.4), value: power), alignment: .leading
                    )
            }
            .frame(height: 12)
        }
    }
}
