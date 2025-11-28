# Cosmic Catch – Developer Onboarding

## Prerequisites
- Xcode 15.3 or newer
- iOS 17 simulators installed (iPhone 14/15 recommended)
- Homebrew tools: `xcbeautify` (for the build script) and `swiftlint` if you want linting locally

## Initial Setup
1. Clone the repository and run `git submodule update --init` if submodules are introduced later.
2. Open `CosmicCatch.xcodeproj` in Xcode or run `xed .`.
3. Select the `CosmicCatch` scheme and the iPhone simulator of your choice.
4. Build + run – the splash/title screen should appear, followed by the interactive menu stack.

## Project Tour
- `CosmicCatch/App` – Dependency container (`GameSessionCoordinator`) and shared debug settings.
- `CosmicCatch/GameCore` – Core data models, mission definitions, services, and simulation helpers.
- `CosmicCatch/Scenes` – SpriteKit gameplay with pooling, VFX, and touch handling.
- `CosmicCatch/ViewModels` – SwiftUI-friendly wrappers for state exposure.
- `CosmicCatch/Views` – SwiftUI components (HUD, menus, overlays, debug tools).
- `CosmicCatchTests` – Unit tests for scoring and session coordination.
- `scripts/build_and_test.sh` – Deterministic build + test pipeline for CI.

## Common Workflows
- **Running smoke tests** – toggle the Debug overlay’s auto-play to watch a simulated session without user input.
- **Balancing spawns** – adjust the spawn rate slider in the Debug overlay, collect telemetry logs in `Documents/telemetry.log`, then craft tuning notes.
- **Adding collectibles** – extend `CollectibleDefinition.defaultCatalog` or drop a JSON file at `CosmicCatch/Resources/ObjectDefinitions.json` and the spawner will pick it up.

## Coding Guidelines
- MVVM boundaries are enforced: SwiftUI views never call SpriteKit APIs directly.
- Favor dependency injection via `GameSessionCoordinator` for anything that touches services.
- Keep SpriteKit node creation lean—reuse `CollectibleNodePool` and prefer procedural art.

## Commands
- `./scripts/build_and_test.sh` – Runs Release build + unit tests with `xcbeautify` output.
- `swift test` – Not supported; the app relies on the Xcode project, so use `xcodebuild`.

## Troubleshooting
- **Missing xcbeautify** – install via `brew install xcbeautify` or remove the pipe in the script.
- **Simulator audio/haptics** – the engines are stubbed; actual devices will play using system APIs.
- **App hangs on splash** – ensure `AppFlowViewModel.handleAppLaunch()` is called once. Hot reloading in previews may require tapping “Skip Splash”.
