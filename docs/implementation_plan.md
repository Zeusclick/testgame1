# Cosmic Catch – Implementation Plan

> Rules for the Agent:
> - Treat each lowest-level bullet (T1.1, T1.2, …) as a separate task.
> - In **automatic mode** you are allowed to execute several tasks sequentially in a single run (see .cursorrules for details).
> - Do **not** write Swift code inside this document.

---

## Phase 1 – Foundation & Shell
- **T1.1** – Create the `CosmicCatch` Xcode project (Swift 5+, iOS 17+, iPhone portrait) with SwiftUI + SpriteKit targets.
- **T1.2** – Build the SwiftUI entry stack (splash, title screen, game view routing, basic pause overlay).
- **T1.3** – Define the GameSession coordinator/view-model graph plus dependency container for services.
- **T1.4** – Introduce GameCore service protocols (spawner, scoring, settings) and stub implementations.
- **T1.5** – Create reusable HUD components (score, lives, combo, timers) with design tokens.
- **T1.6** – Establish the shared design system (colors, gradients, typography, spacing, glow styles).
- **T1.7** – Implement geometry + safe-area utilities that normalize layouts across all iPhone portrait sizes.
- **T1.8** – Add developer/debug overlays (FPS, spawn rate sliders, slow-motion toggle) accessible in debug builds.
- **T1.9** – Document the architecture and responsibilities in `docs/architecture.md` (views, view models, scenes, services).
- **T1.10** – Create a unit-test target and seed tests for GameState/GameSession behaviors.
- **T1.11** – Configure a reproducible build/test script (Fastlane or xcodebuild wrapper) for CI hooks.
- **T1.12** – Write developer onboarding + environment setup instructions in the docs folder.

## Phase 2 – Core Gameplay Loop
- **T2.1** – Implement the falling-object spawn scheduler with deterministic seeding and difficulty hooks.
- **T2.2** – Build the touch/catch detection pipeline that maps taps/drags to SpriteKit nodes accurately.
- **T2.3** – Create scoring + life/miss logic plus combo handling tied to GameState updates.
- **T2.4** – Wire pause/resume/quit state transitions between SwiftUI and SpriteKit.
- **T2.5** – Add failure + restart transitions, including animated overlays and retry options.
- **T2.6** – Build a first-run tutorial overlay explaining controls and objectives.
- **T2.7** – Implement object pooling + node reuse for performant spawning at 60 FPS.
- **T2.8** – Add baseline particle trails for spawn, idle, hit, and miss states.
- **T2.9** – Create a debug timeline visualizer that replays the last few seconds of game events.
- **T2.10** – Hook HUD updates and haptics to real-time gameplay events.
- **T2.11** – Persist session summaries (score, accuracy, duration) locally for later use.
- **T2.12** – Build a smoke-test harness that can auto-run a simulated session for regression checks.

## Phase 3 – Object Systems & Power-Ups
- **T3.1** – Define the object taxonomy (stellar shards, plasma orbs, void mines, relic cores, etc.).
- **T3.2** – Load object definitions from data (JSON/Plist) to drive speeds, behaviors, and rarity.
- **T3.3** – Create multi-state animations (spawn, idle/fall, tap/hit, miss/despawn) per object type.
- **T3.4** – Implement collectible power-ups with temporary buffs (slow motion, score boost, shield).
- **T3.5** – Add hazard objects that penalize the player when tapped or missed.
- **T3.6** – Build object-specific VFX trails and shader glows for visual differentiation.
- **T3.7** – Tie scoring modifiers and combo bonuses to object metadata.
- **T3.8** – Introduce rare “event” objects (comets, wormholes) with unique interactions.
- **T3.9** – Integrate per-object audio cues and haptics.
- **T3.10** – Create a Codex view describing each object, unlock conditions, and stats.
- **T3.11** – Build a balancing/debug tool that visualizes spawn weights and probabilities.
- **T3.12** – Add telemetry logs (local-only) capturing object performance for tuning.

## Phase 4 – Progression & Difficulty
- **T4.1** – Implement sector/level progression with curated wave definitions.
- **T4.2** – Build adaptive difficulty curves that react to player accuracy/combo streaks.
- **T4.3** – Add mission/goal cards for each sector with rewards.
- **T4.4** – Implement mid-run modifiers (gravity shifts, wind bursts, time dilation events).
- **T4.5** – Create a power meter and ultimate ability that clears or slows objects.
- **T4.6** – Add persistent meta progression (soft currency, unlock tokens) stored locally.
- **T4.7** – Build a run summary screen with detailed stats, accuracy graphs, and notable moments.
- **T4.8** – Implement achievements and local leaderboards/high scores.
- **T4.9** – Persist settings, unlocks, and stats with robust migration handling.
- **T4.10** – Add dynamic background/sector theming that tracks progression.
- **T4.11** – Build challenge modes (endless, timed blitz, precision) selectable from the menu.
- **T4.12** – Provide balancing scripts/reports to validate tuning.

## Phase 5 – Audio, FX & Presentation
- **T5.1** – Integrate adaptive music layers that react to intensity.
- **T5.2** – Design the SFX kit (catch, miss, power-up, UI) and hook up playback.
- **T5.3** – Implement an audio mixer with master/music/SFX/haptic controls.
- **T5.4** – Create advanced particle emitters for object states and ambient effects.
- **T5.5** – Build parallax nebula/starfield backgrounds with multiple depth layers.
- **T5.6** – Add camera shakes, screen pulses, and bloom for impactful feedback.
- **T5.7** – Implement shader-driven glow, distortion, and chromatic aberration effects.
- **T5.8** – Build a cinematic intro/attract mode that plays on the title screen.
- **T5.9** – Integrate CoreHaptics patterns coordinated with gameplay beats.
- **T5.10** – Add accessibility-friendly color filters and contrast controls.
- **T5.11** – Create a photo/video capture mode that exports locally without networking.
- **T5.12** – Optimize SpriteKit node counts, materials, and timing to guarantee 60 FPS on target devices.

## Phase 6 – Menus, Meta & Economy
- **T6.1** – Build the main menu navigation stack (Play, Codex, Challenges, Settings, Profile).
- **T6.2** – Implement the Settings screen (audio, haptics, accessibility, difficulty, controls).
- **T6.3** – Create the Player Profile view with stats, achievements, and cosmetics.
- **T6.4** – Develop the Codex UI surfacing object lore and unlock tips.
- **T6.5** – Add a Challenge/Mode selector UI that surfaces requirements and rewards.
- **T6.6** – Implement a cosmetic/customization screen (colors, trails, HUD themes) tied to soft currency.
- **T6.7** – Build the upgrade/currency system (earn-only, no networking or IAP).
- **T6.8** – Create the in-run pause menu overlay with resume, restart, quit, and help options.
- **T6.9** – Polish the run summary/performance view with charts and insights.
- **T6.10** – Add localization scaffolding plus a sample translation bundle.
- **T6.11** – Provide data reset/backup utilities (local file export/import if feasible).
- **T6.12** – Refine menu transitions, gestures, and haptic feedback for premium feel.

## Phase 7 – Polish, Performance & QA
- **T7.1** – Instrument runtime metrics (frame time, memory, node counts) and create dashboards.
- **T7.2** – Optimize asset loading, texture atlases, and pooling to reduce memory spikes.
- **T7.3** – Expand unit/UI test coverage (XCTest + snapshot tests) for critical flows.
- **T7.4** – Build a manual QA checklist and regression script for testers.
- **T7.5** – Harden error handling/logging (local files) for crashes or invalid states.
- **T7.6** – Validate layouts on every supported iPhone size and dynamic type category.
- **T7.7** – Complete accessibility pass (VoiceOver labels, motion reduction, colorblind modes).
- **T7.8** – Tune difficulty curves, spawn weights, and rewards using playtest data.
- **T7.9** – Finalize art polish for HUD, menus, and object visuals.
- **T7.10** – Master audio mix levels and final balance.
- **T7.11** – Conduct a final bug bash and triage outstanding issues.
- **T7.12** – Lock the release candidate build and tag the repository.

## Phase 8 – Launch Prep & Post Launch
- **T8.1** – Prepare App Store metadata (description, keywords, support URL placeholder).
- **T8.2** – Capture marketing screenshots and short clips (stored locally).
- **T8.3** – Produce final icon variants, banners, and promotional art.
- **T8.4** – Draft release notes and website/press copy.
- **T8.5** – Document TestFlight submission steps and verification checklist.
- **T8.6** – Perform final compliance/privacy review (confirm no networking, analytics, or tracking).
- **T8.7** – Write the support/FAQ document and troubleshooting tips.
- **T8.8** – Plan the post-launch roadmap/backlog for future updates.
- **T8.9** – Compile a project retrospective and architecture overview for handoff.
- **T8.10** – Prepare social/marketing assets (text + imagery) for launch day.
- **T8.11** – Track App Store review status and document follow-up actions (no automated polling).
- **T8.12** – Transition to maintenance mode (issue triage template, update cadence plan).
