import SwiftUI

struct MenuStackView: View {
    @EnvironmentObject private var menuViewModel: MenuViewModel
    @EnvironmentObject private var coordinator: GameSessionCoordinator
    @EnvironmentObject private var appFlow: AppFlowViewModel
    @EnvironmentObject private var gameViewModel: GameViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Picker("Menu", selection: $menuViewModel.selectedTab) {
                ForEach(MenuViewModel.Tab.allCases) { tab in
                    Text(tab.rawValue.capitalized).tag(tab)
                }
            }
            .pickerStyle(.segmented)

            switch menuViewModel.selectedTab {
            case .play:
                playPanel
            case .codex:
                codexPanel
            case .challenges:
                challengePanel
            case .settings:
                settingsPanel
            case .profile:
                profilePanel
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(radius: 20)
        .onAppear {
            menuViewModel.assignHistory(coordinator.recentSummaries())
        }
    }

    private var playPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose Sector")
                .font(.headline)
            Picker("Sector", selection: $menuViewModel.selectedSector) {
                Text(SectorDefinition.coreNebula.name).tag(SectorDefinition.coreNebula)
            }
            .pickerStyle(.segmented)
            Button("Launch Mission") {
                appFlow.startGame(using: gameViewModel, challenge: menuViewModel.selectedChallenge, sector: menuViewModel.selectedSector)
            }
            .buttonStyle(CosmicCapsuleButtonStyle())
        }
    }

    private var codexPanel: some View {
        ScrollView {
            ForEach(menuViewModel.codexEntries) { entry in
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.displayName).bold()
                    Text(entry.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 6)
                Divider()
            }
        }
        .frame(maxHeight: 200)
    }

    private var challengePanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Challenge Mode")
                .font(.headline)
            Picker("Challenge", selection: $menuViewModel.selectedChallenge) {
                ForEach(ChallengeMode.allCases) { mode in
                    Text(mode.rawValue.capitalized).tag(mode)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var settingsPanel: some View {
        SettingsDetailView()
    }

    private var profilePanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Runs")
                .font(.headline)
            ForEach(menuViewModel.runHistory) { summary in
                HStack {
                    Text(summary.date, style: .date)
                    Spacer()
                    Text("\(summary.score)")
                }
            }
        }
        .frame(maxHeight: 200)
    }
}

struct SettingsDetailView: View {
    @EnvironmentObject private var settingsViewModel: SettingsViewModel

    var body: some View {
        Form {
            Section("Audio") {
                Slider(value: $settingsViewModel.musicVolume, in: 0...1) {
                    Text("Music")
                }
                Slider(value: $settingsViewModel.sfxVolume, in: 0...1) {
                    Text("SFX")
                }
                Toggle("Haptics", isOn: $settingsViewModel.hapticsEnabled)
            }
            Section("Accessibility") {
                Toggle("High Contrast", isOn: $settingsViewModel.accessibility.highContrastHUD)
                Toggle("Color Blind Mode", isOn: $settingsViewModel.accessibility.colorBlindMode)
                Toggle("Reduce Motion", isOn: $settingsViewModel.accessibility.reduceMotion)
            }
            Button("Save Settings") {
                settingsViewModel.persist()
            }
        }
        .frame(maxHeight: 220)
    }
}
