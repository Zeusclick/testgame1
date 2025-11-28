# Cosmic Catch – Architecture Overview

## Layering

- **SwiftUI Shell** – Hosts navigation, menus, overlays, HUD, and developer/debug surfaces. `ContentView` composes the active screen, while specialized views such as `MenuStackView`, `HUDView`, `TutorialOverlayView`, and `RunSummaryView` handle focused UI responsibilities.
- **View Models** – `GameViewModel` bridges SpriteKit gameplay to the SwiftUI world. `GameSessionCoordinator` owns the authoritative `GameState`, orchestrates services, and exposes typed view models (`HUDViewModel`, `MenuViewModel`, `SettingsViewModel`, etc.) so SwiftUI never touches SpriteKit directly.
- **GameCore** – All gameplay data and rules live under `GameCore`. `GameState` captures scoring, combos, lives, missions, modifiers, sectors, and progression. Service protocols (`ObjectSpawnerService`, `ScoringService`, `SettingsStore`, `SessionSummaryStore`, `AudioEngine`, `HapticsEngine`) make the Session Coordinator fully testable and mockable.
- **SpriteKit Scene** – `GameScene` renders the playfield. It receives spawn events from the coordinator, uses reusable `CollectibleNode` instances, animates the four required states (spawn, idle, tap/hit, miss/despawn), and reports gameplay events back through `GameSceneDelegate`.
- **Services & Utilities** – `DefaultObjectSpawnerService` (deterministic spawn scheduling), `DifficultyDirector`, `TelemetryLogger`, `SmokeTestHarness`, and `TimelineRecorder` encapsulate non-UI concerns. `GeometryUtilities` and `DesignSystem` provide layout + style primitives consumed by SwiftUI views.

## Data Flow

```
SpriteKit Touches -> GameScene -> GameViewModel -> GameSessionCoordinator -> GameState/Services
GameState changes -> HUDViewModel/HUDView + Menu/Profile summaries
Debug toggles -> DebugSettings -> GameViewModel -> GameScene tuning
```

## Key Responsibilities

- **GameSessionCoordinator** – Session lifecycle, pause/resume, mission progression, session summaries, power meter, modifiers, audio/haptics dispatch, timeline tracking.
- **GameViewModel** – Owns the SpriteKit scene, applies viewport changes, forwards gameplay callbacks to the coordinator, and reacts to debug toggles (spawn rate, slow motion, auto-play).
- **Services** – Provide interchangeable behaviors. Example: swapping the scoring model or persistence store for tests is a constructor-only change.
- **View Models** – Lightweight, Combine-driven adapters so SwiftUI views never query the coordinator directly.
- **Debug + QA** – Debug overlay toggles spawn multipliers, slow motion, auto-play, FPS display, and exposes the live timeline. `SmokeTestHarness` simulates deterministic sessions for regression checks.

## Testing & Tooling

- `CosmicCatchTests` target contains unit tests for `GameState` scoring/miss logic and the session coordinator’s pause/resume pipeline.
- `scripts/build_and_test.sh` wraps `xcodebuild` invocations for CI repeatability.

This structure keeps MVVM boundaries crisp, isolates SpriteKit rendering in `GameScene`, and makes it feasible to expand future systems (power-ups, economy, post-launch content) without touching presentation code.
