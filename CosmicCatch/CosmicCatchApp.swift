import SwiftUI

@main
struct CosmicCatchApp: App {
    @StateObject private var gameViewModel = GameViewModel()
    @StateObject private var appFlowViewModel = AppFlowViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameViewModel)
                .environmentObject(appFlowViewModel)
        }
    }
}
