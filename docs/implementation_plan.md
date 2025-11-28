# Cosmic Catch – Implementation Plan

> Rules:
> - Each **bullet at the lowest level** is considered a single task.
> - One Agent run = one task.
> - Do **not** write Swift code in these docs; code goes in `.swift` files only.
> - When a task involves sprite/animation art, generate multiple frames using slightly different prompts/parameters for each frame.

Task IDs are hints; they do not need to be enforced by the Agent but help tracking.

---

## Phase 1 – Project Setup & Architecture

### 1.1 Xcode Project & Structure

- **T1.1** – Create `CosmicCatch` iOS app project (Swift 5+, iOS 17+, iPhone‑only, portrait).
- **T1.2** – Set up folder/group structure:
  - `App`, `GameCore`, `GameScene`, `Models`, `ViewModels`, `Views`, `Assets`, `VFX`, `Audio`, `Support`, `Tests`.
- **T1.3** – Configure build settings:
  - Disable unused capabilities, set minimum iOS.
- **T1.4** – Add basic app assets placeholders (app icon set, accent colors in Asset Catalog).

### 1.2 App Entry & MVVM Skeleton

- **T1.5** – Implement `CosmicCatchApp` SwiftUI entry with root `ContentView`.
- **T1.6** – Create `AppState` as `ObservableObject` to track global state (current screen, settings).
- **T1.7** – Create initial SwiftUI views:
  - `MainMenuView`, `GameContainerView`, `SettingsView`, `InfoView` (simple placeholders).
- **T1.8** – Define initial navigation flow between views using `AppState`.

### 1.3 SpriteKit Integration

- **T1.9** – Implement reusable SwiftUI wrapper for SpriteKit (`GameSceneView`) to host SKScene.
- **T1.10** – Create empty `GameScene` subclass with basic lifecycle methods (`didMove`, `update`, etc.).
- **T1.11** – Wire `GameContainerView` to present `GameScene` using the SwiftUI wrapper.

---

## Phase 2 – Core Gameplay Loop & Data Models

### 2.1 Game State & Models

- **T2.1** – Define core models:
  - `FallingObjectType`, `Alignment`, `Sector`, `LevelConfig`, `ScoreState`, `LifeState`, `ComboState`.
- **T2.2** – Implement `GameSession` model with:
  - Current score, lives, level, sector, combo, multiplier, run state.
- **T2.3** – Create `GameViewModel` (ObservableObject) to mediate between SwiftUI and `GameScene`.

### 2.2 Spawning & Movement

- **T2.4** – Implement `SpawnManager` (in GameCore) to handle:
  - Spawn timing, randomness, and patterns using `LevelConfig`.
- **T2.5** – Implement base `FallingObjectNode` SKNode/SKSpriteNode subclass:
  - Common properties: type, alignment, current state (spawn/idle/hit/miss).
- **T2.6** – Implement vertical movement system:
  - Either via physics or manual per‑frame position updates, with level‑based speed.
- **T2.7** – Add basic X spawn distribution and simple horizontal drift for objects.

### 2.3 Input & Interaction

- **T2.8** – Implement touch handling in `GameScene`:
  - Convert touches to node hit tests.
  - Dispatch interactions to `FallingObjectNode` and `GameViewModel`.
- **T2.9** – Implement GOOD/BAD tap handling:
  - Trigger callbacks to update score/lives/combos.
  - Trigger node animation state changes.

### 2.4 Run Lifecycle

- **T2.10** – Implement start/run/end logic:
  - Start new run from menu, reset state.
  - Detect game over (lives <= 0), notify `GameViewModel`.
- **T2.11** – Implement pause/resume logic:
  - Pause SpriteKit scene and game timers via view model.
- **T2.12** – Implement “run reset” flow to quickly restart a new game.

---

## Phase 3 – Level, Sector & Difficulty System

### 3.1 Level Config & Progression

- **T3.1** – Implement `LevelConfig` structure with:
  - Spawn rate, object weights, fall speed, max objects, patterns.
- **T3.2** – Define `Sector` model to group levels with visual theme indicators.
- **T3.3** – Create initial configuration data for Sectors 1–3 (e.g., in JSON or static structs).

### 3.2 Level Logic

- **T3.4** – Implement level progression:
  - Increase level when score thresholds are reached.
- **T3.5** – Implement sector transition logic:
  - Map levels to sectors and notify background/UI when sector changes.
- **T3.6** – Apply difficulty curves:
  - Adjust spawn rate, fall speed, object types unlocked per level and sector.

---

## Phase 4 – HUD & Menus

### 4.1 In‑Game HUD

- **T4.1** – Implement HUD SwiftUI overlay:
  - Score label with stylized neon text.
  - Level/sector indicator.
  - Lives display with icons.
  - Combo/multiplier display with simple highlight animation.
- **T4.2** – Connect HUD to `GameViewModel` with live updates.

### 4.2 Menus & Settings

- **T4.3** – Implement full `MainMenuView` UI matching visual spec.
- **T4.4** – Implement `SettingsView` with:
  - Music/SFX sliders, haptics toggle, colorblind mode, reduce motion.
- **T4.5** – Implement `InfoView` for credits and brief instructions.
- **T4.6** – Add overlay views:
  - Pause overlay with Resume/Quit.
  - Game Over overlay (score, best score, stats).

### 4.3 Persistence

- **T4.7** – Implement settings persistence (UserDefaults).
- **T4.8** – Implement high score and best level persistence.

---

## Phase 5 – Base Visuals & FX Framework

### 5.1 Background & Parallax

- **T5.1** – Implement base parallax background in `GameScene` with:
  - Multi‑layer starfields, nebula, and distant planets using SKNodes.
- **T5.2** – Implement dynamic sector‑based color grading (tinting and gradient overlays).
- **T5.3** – Add meteor streak particles occasionally spawning in the background.

### 5.2 Generic FX Components

- **T5.4** – Implement particle system templates for:
  - Collect burst, hit explosion, miss fade.
- **T5.5** – Implement screen feedback utilities:
  - Screen shake, flash overlays, mild color tint.

### 5.3 Art/Animation Infrastructure

- **T5.6** – Define animation state machine in `FallingObjectNode`:
  - Spawn → Idle → (Hit | Miss) → Cleanup.
- **T5.7** – Implement helper for sprite animations:
  - Frame sequences (texture arrays or procedural keyframes).
- **T5.8** – Implement helper for generating glow and gradient effects (SKShapeNode, shaders).

---

## Phase 6 – Object Types (Art & Code)

> Important:  
> - Each task below corresponds to **one object state set** (art + behavior integration).  
> - Within each task, generate multiple frames per animation state (spawn, idle, hit, miss) and use **different prompts/variations per frame** when creating sprite textures.

### 6.1 GOOD Objects

- **T6.1** – Stellar Shard (GOOD, common)
  - Implement sprite, glow, spawn/idle/hit/miss animations, collect logic, and particles.

- **T6.2** – Plasma Orb (GOOD, common)
  - Orb with internal plasma swirl; implement shader/texture, animations, and collect effect.

- **T6.3** – Quantum Crystal (GOOD, uncommon)
  - Faceted gem; implement facet pulse animation and prism‑burst hit effect.

- **T6.4** – Nano Satellite (GOOD, uncommon)
  - Satellite with panels; implement slight flap/spin animations and debris burst on tap.

- **T6.5** – Cosmic Coin (GOOD, common)
  - Coin flip animation, golden glow, and particle rain on collect.

- **T6.6** – Aurora Seed (GOOD, rare)
  - Vertical aurora trail; implement idle aura and column burst on tap.

- **T6.7** – Gravity Cube (GOOD, rare)
  - Inner/outer cube rotations; implement ring shockwave on collect.

- **T6.8** – Solar Battery (GOOD, common)
  - Sloshing energy fill, idle wobble, and upward energy burst on tap.

- **T6.9** – Comet Chunk (GOOD, uncommon)
  - Rock with tail; implement trail particles and fragmentation burst on tap.

- **T6.10** – Data Capsule (GOOD, rare)
  - Binary digits inside; implement scrolling digits and scatter effect on tap.

- **T6.11** – Flux Ring (GOOD, special)
  - Torus ring; implement smooth ring rotation and screen‑tint wave on collect (multiplier boost).

- **T6.12** – Time Fragment (GOOD, special)
  - Time fragment sprite; implement distortion ripple and slow‑motion trigger on tap.

### 6.2 BAD Objects

- **T6.13** – Corrupted Asteroid (BAD, common)
  - Cracked rock; implement flickering cracks and shard explosion on tap.

- **T6.14** – Void Mine (BAD, hazard)
  - Spiky black hole orb; implement core distortion and suck‑in animation on tap.

- **T6.15** – EMP Spike (BAD, hazard)
  - Electric spike; implement arc animations and edge electric flicker on tap.

- **T6.16** – Radiation Barrel (BAD, hazard)
  - Toxic barrel; ooze drips, toxic explosion and green screen tint on tap.

- **T6.17** – Rogue Drone (BAD, mobile)
  - Triangular drone; implement eye scanning, zig‑zag path, glitch disintegration on tap.

- **T6.18** – Glitch Cube (BAD, tricky)
  - Pixel noise cube; implement glitch shader and brief screen glitch on tap.

- **T6.19** – Sawblade Satellite (BAD, danger)
  - Spinning blade; sparks and metallic SFX on tap.

- **T6.20** – Time Bomb (BAD, hazard)
  - Timer orb; pulsing faster near bottom, explosion with strong feedback on tap.

- **T6.21** – Ice Shard Cluster (BAD, slowdown)
  - Frost cluster; frosty aura and screen frost overlay on tap.

- **T6.22** – Toxic Spore Pod (BAD, hazard)
  - Pod with spores; lingering toxic cloud that affects visibility on tap.

### 6.3 SPECIAL Objects

- **T6.23** – Shield Core (SPECIAL, GOOD)
  - Shield sphere; implement shield ripple animation and life increment effect.

- **T6.24** – Screen Cleaner Pulse (SPECIAL, GOOD)
  - Orb with rings; implement radial wave that clears BAD objects.

- **T6.25** – Score Crystal Cluster (SPECIAL, GOOD)
  - Rainbow crystals; implement high‑value collect effect, multi‑number popups.

---

## Phase 7 – Audio & Haptics

### 7.1 Audio Infrastructure

- **T7.1** – Implement `AudioManager`:
  - Background music playback, SFX playback, volume controls.
- **T7.2** – Integrate AudioManager with Settings (volume sliders).

### 7.2 SFX & Music Integration

- **T7.3** – Add and wire background music for at least 2 different sectors.
- **T7.4** – Add SFX for:
  - GOOD collect, BAD hit, powerups, level up, game over.
- **T7.5** – Add small pitch variations/randomization for frequently repeated sounds.

### 7.3 Haptics

- **T7.6** – Implement HapticManager wrapper.
- **T7.7** – Integrate haptics for:
  - GOOD collect, BAD tap, life loss, game over, powerups.
- **T7.8** – Wire haptics toggle to Settings.

---

## Phase 8 – Polish, Performance & Accessibility

### 8.1 Performance

- **T8.1** – Profile and optimize SpriteKit:
  - Node counts, texture usage, particle caps.
- **T8.2** – Optimize object pooling:
  - Reuse nodes and emitters instead of recreating.
- **T8.3** – Verify consistent 60 FPS across simulated devices and typical loads.

### 8.2 Visual & UX Polish

- **T8.4** – Refine HUD animations (score pop, combo pulses, level‑up flashes).
- **T8.5** – Add transition animations between menu and game (fades, zooms).
- **T8.6** – Refine sector color grades and subtle background animations.

### 8.3 Accessibility & Options

- **T8.7** – Implement colorblind mode palette adjustments (GOOD vs BAD clarity).
- **T8.8** – Implement Reduce Motion:
  - Disable excessive particles, reduce parallax, simplify animations.
- **T8.9** – Add any remaining control hints/tutorial overlays.

### 8.4 Final QA & Cleanup

- **T8.10** – Pass through UI on all iPhone sizes to ensure correct layout and safe‑area usage.
- **T8.11** – Clean up code (remove unused assets, tidy structure, documentation comments).
- **T8.12** – Final smoke tests for:
  - New game, pause/resume, game over, settings, persistence, and performance.
