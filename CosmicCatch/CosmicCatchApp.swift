import SwiftUI

@main
struct CosmicCatchApp: App {
    @StateObject private var coordinator: GameSessionCoordinator
    @StateObject private var gameViewModel: GameViewModel
    @StateObject private var appFlowViewModel = AppFlowViewModel()

    init() {
        let coordinator = GameSessionCoordinator()
        _coordinator = StateObject(wrappedValue: coordinator)
        _gameViewModel = StateObject(wrappedValue: GameViewModel(coordinator: coordinator))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameViewModel)
                .environmentObject(appFlowViewModel)
                .environmentObject(coordinator)
                .environmentObject(coordinator.hudViewModel)
                .environmentObject(coordinator.menuViewModel)
                .environmentObject(coordinator.settingsViewModel)
                .environmentObject(coordinator.tutorialViewModel)
                .environmentObject(coordinator.runSummaryViewModel)
                .environmentObject(coordinator.debugSettings)
        }
    }
}
