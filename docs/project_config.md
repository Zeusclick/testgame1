# Cosmic Catch – Project Configuration

Tier‑1 iPhone arcade game: single‑screen, portrait space catcher with high‑end visual polish, fluid animation, and tight touch controls.

---

## 1. Technical Overview

- **Platform:** iOS 17+, iPhone only
- **Orientation:** Portrait
- **Languages / Frameworks:**
  - Swift 5+
  - SwiftUI for app shell, menus, overlays, HUD container
  - SpriteKit for gameplay (SKScene, SKSpriteNode/ShapeNode, physics, particles)
  - MVVM with `ObservableObject` view models
- **Rendering & Performance:**
  - Target 60 FPS on all modern iPhones
  - Fixed logical update step; SpriteKit rendering at device refresh
  - Max on‑screen active falling objects: ~35–45 (adaptive by device)
  - Max active particle nodes: aggressively pooled, capped to avoid frame drops
  - Avoid heavy per‑frame allocations and synchronous I/O on main thread

- **No:** WebKit, ads, tracking, external analytics. Local storage only (UserDefaults / local files).

---

## 2. Core Game Loop

1. **Start run**
   - Player taps “Play” (or “Resume”).
   - GameScene resets state: score=0, lives=3, level=1, combo=0, multiplier=1.0.
   - Initial object set = easy and visually clear GOOD/BAD items.

2. **Gameplay**
   - Objects spawn at top (just off screen) at positions across X range, with:
     - Level‑dependent spawn cadence, patterns, and fall speeds.
     - Each object type has:
       - Alignment: GOOD / BAD / SPECIAL
       - Base score / penalty
       - Optional side effect (slow time, clear screen, etc.).
   - Objects fall vertically with small horizontal drift and wobble, plus rotation.
   - Player taps anywhere:
     - If tap hits a GOOD object:
       - Object plays “collect” animation and despawns.
       - Score increases; combo and multiplier updated.
       - Positive haptics + SFX.
     - If tap hits a BAD object:
       - Object plays “hit” failure animation and despawns.
       - Player loses life and/or score.
       - Negative haptics + SFX, screen feedback.
   - If a GOOD object reaches bottom without being tapped:
     - Counted as a miss → lose life / combo break / small penalty.
     - Plays “miss/despawn” animation (fade, disintegration).
   - If a BAD object reaches bottom:
     - Usually no penalty, maybe tiny score bonus for “successful avoidance” for some types.

3. **Level progression**
   - Score thresholds trigger level‑up:
     - Level 1 → 2 at e.g. 1,000 points, then progressively higher.
   - Level‑up does:
     - Increases fall speed / spawn rate.
     - Introduces new object types and patterns.
     - Slight color shift / background variation for sense of progression.
   - Infinite levels, but grouped into named “Sectors” (visual themes).

4. **End of run**
   - Lives reach 0 → slow‑motion effect → Game Over overlay.
   - Show summary: score, highest level, best combo, new records.
   - Offer options: Retry, Return to Menu.

---

## 3. Input & Controls

- **Primary input:** Tap.
- **Behavior:**
  - Multi‑touch: multiple objects can be collected near‑simultaneously.
  - Ignore taps on UI overlays (pause, buttons).
  - Hit test uses object’s texture or slightly larger physics body for generous feel.
- **Responsiveness:**
  - Touch handling must be immediate with animations triggered same frame.
  - Haptics and SFX triggered with minimal delay.

---

## 4. Game States & Navigation

- **App States:**
  - Boot / Splash → Main Menu → (Settings / Info) → Game (Playing / Paused / Game Over).
- **Main Menu:**
  - Game logo / title “Cosmic Catch”
  - Buttons: Play, Settings, Info, Mute toggle, maybe “Skins/Ship” (cosmetic only).
- **Settings:**
  - Music volume slider
  - SFX volume slider
  - Haptics on/off
  - Colorblind-friendly mode
  - Reduce Motion toggle
- **In‑Game States:**
  - Playing
  - Paused (dimmed overlay, large Resume / Quit buttons)
  - Game Over overlay

---

## 5. HUD & UI Layout

- Portrait, safe‑area aware, responsive to all iPhone sizes.

- **In‑Game HUD (top region):**
  - Score (prominent)
  - Level / Sector indicator
  - Lives (icons, e.g. hearts or shields)
  - Combo / multiplier indicator with subtle animations (pulse on change).
- **Bottom / corners:**
  - Pause button (top‑right).
  - Optional powerup indicators (slots with cooldown rings).
- **Visual style:**
  - Minimalistic, neon lines and gradients to match cosmic theme.
  - Use SF Symbols where possible, stylized with glow/shadow.

---

## 6. Visual Style & VFX

- **Overall Art Direction:**
  - Dark cosmic backdrop (deep blues, purples, blacks) with neon accents.
  - Layered parallax: distant stars, drifting nebula clouds, slow parallax planets.
  - Heavy use of glows, bloom, additive blending.
  - Prefer procedural / vector‑like rendering using:
    - `SKShapeNode` with gradient fills.
    - Custom `SKShader` for glows, radial gradients, distortions.
    - Minimal reliance on external PNGs (allowed only when SpriteKit tools are insufficient).

- **Background:**
  - At least 3–4 layered starfields:
    - Static faint stars.
    - Slowly scrolling large stars.
    - Occasional meteor streak particle systems.
  - Sector‑based color grading (e.g., blue, magenta, greenish, golden).

- **Particles:**
  - Use `SKEmitterNode` for:
    - Object trails (energy orbs, comets).
    - Tap impacts (bursts, shockwaves).
    - Miss/despawn effects (disintegration, smoke).
  - Reuse emitters via pooling where possible.

- **Animations (per object):**
  - Spawn / Entry
  - Idle / Falling loop (subtle wobble/spin)
  - Tap/Hit reaction
  - Miss/Despawn

  For animation sprites: **each animation state for each object** should have multiple frames with slightly different visual prompts when generating textures, to avoid robotic repetition and to enhance organic motion.

---

## 7. Object Taxonomy (20+ Distinct Types)

Each object has:

- **Alignment:** GOOD / BAD / SPECIAL
- **Role:** Basic score, high‑value, hazard, powerup, etc.
- **Visual style:** Shape / color palette / glow idea.
- **Unique animation hook:** Something visually distinctive in at least one state.

### 7.1 GOOD Objects (Collect)

1. **Stellar Shard**
   - Type: GOOD / common
   - Visual: Small glowing crystal shard, cyan with white core.
   - Animation: Twinkling core, gentle spin; spawn by materializing from a flash.

2. **Plasma Orb**
   - Type: GOOD / common
   - Visual: Round orb with swirling plasma inside (blue/green).
   - Animation: Inner swirl shader; spawn scaling from 0; hit = quick implosion.

3. **Quantum Crystal**
   - Type: GOOD / uncommon
   - Visual: Multi‑faceted gem, magenta and purple gradients.
   - Animation: Facets pulse sequentially; tap = prism‑like burst with light rays.

4. **Nano Satellite**
   - Type: GOOD / uncommon
   - Visual: Tiny stylized satellite with solar panels.
   - Animation: Slight panel flap; spinning; hit = panels detach as tiny debris particles.

5. **Cosmic Coin**
   - Type: GOOD / common
   - Visual: Neon ring coin, gold/orange with outer glow.
   - Animation: Coin flip around vertical axis; tap = coin rains / sparks downward.

6. **Aurora Seed**
   - Type: GOOD / rare
   - Visual: Seed‑like capsule emitting vertical aurora trails.
   - Animation: Subtle oscillation; tap = vertical aurora burst.

7. **Gravity Cube**
   - Type: GOOD / rare
   - Visual: Wireframe cube with rotating inner cube.
   - Animation: Inner cube rotates at different speed; tap = radial shockwave ring.

8. **Solar Battery**
   - Type: GOOD / common
   - Visual: Battery icon filled with glowing yellow fluid.
   - Animation: Fill slightly sloshes; tap = fill launches upward as particles.

9. **Comet Chunk**
   - Type: GOOD / uncommon
   - Visual: Rock chunk with icy tail.
   - Animation: Tail particles trail behind; tap = chunk fragments into smaller glowing bits.

10. **Data Capsule**
    - Type: GOOD / rare
    - Visual: Transparent capsule with binary digits drifting inside.
    - Animation: Digits scroll; tap = digits scatter outward and fade.

11. **Flux Ring**
    - Type: GOOD / special
    - Visual: Floating torus ring, blue/white, with soft glow.
    - Effect: Temporary score multiplier boost on collect.
    - Animation: Slow rotation; tap = expanding ring that briefly tints screen.

12. **Time Fragment**
    - Type: GOOD / special
    - Visual: Shattered clock fragment with starfield reflection.
    - Effect: Brief slow‑motion effect.
    - Animation: Shards rotate; tap = radial distortion ripple.

### 7.2 BAD Objects (Avoid)

13. **Corrupted Asteroid**
    - Type: BAD / common
    - Visual: Jagged dark rock with purple cracks.
    - Animation: Cracks flicker; tap = violent shard explosion + negative SFX.

14. **Void Mine**
    - Type: BAD / hazard
    - Visual: Spiky orb with black hole core.
    - Animation: Core warps background slightly; tap = small “black hole” suck effect and health loss.

15. **EMP Spike**
    - Type: BAD / hazard
    - Visual: Metallic spike with electric arcs.
    - Animation: Arcs hop along body; tap = screen‑edge electric flicker.

16. **Radiation Barrel**
    - Type: BAD / hazard
    - Visual: Barrel with glowing green toxic symbol.
    - Animation: Drips of neon ooze; tap = splash particles and sickly tint.

17. **Rogue Drone**
    - Type: BAD / mobile
    - Visual: Small triangular drone with red eye.
    - Animation: Eye scanning; drone slightly changes horizontal trajectory; tap = glitchy disintegration.

18. **Glitch Cube**
    - Type: BAD / tricky
    - Visual: Pixelated cube with RGB noise shader.
    - Animation: Jitter and flicker; tap = brief screen glitch effect.

19. **Sawblade Satellite**
    - Type: BAD / danger
    - Visual: Circular saw‑satellite with spinning blades.
    - Animation: Fast spin; tap = sparks shower and loud metallic SFX.

20. **Time Bomb**
    - Type: BAD / hazard
    - Visual: Orb with ticking timer digits.
    - Animation: Pulses faster near bottom; if tapped → screen shake, lives/score penalty.

21. **Ice Shard Cluster**
    - Type: BAD / slowdown
    - Visual: Cluster of icy shards with frosty aura.
    - Effect: On tap, temporarily slows player tap response or slightly slows time but with penalty.
    - Animation: Small frost trail; tap = frosty overlay wipes and fades.

22. **Toxic Spore Pod**
    - Type: BAD / hazard
    - Visual: Bulbous pod with floating green spores.
    - Animation: Spore particles slowly leak; tap = large cloud with visibility/reduced clarity for short time.

### 7.3 SPECIAL Objects / Powerups

23. **Shield Core**
    - Type: SPECIAL / GOOD
    - Effect: Adds 1 extra life (up to a max cap).
    - Visual: Sphere with hex shield pattern.
    - Animation: Hex cells ripple; tap = shield briefly flashes around screen edge.

24. **Screen Cleaner Pulse**
    - Type: SPECIAL / GOOD
    - Effect: Clears all BAD objects currently on screen.
    - Visual: Compact orb with concentric rings.
    - Animation: Tap triggers radial wave that sweeps enemies away with dissolve effect.

25. **Score Crystal Cluster**
    - Type: SPECIAL / GOOD
    - Effect: High score bonus and combo boost.
    - Visual: Cluster of multi‑color crystals.
    - Animation: Crystals pulse with rainbow gradient; tap = burst of prism shards and huge number pop‑up.

---

## 8. Animation States (Per Object)

All objects support:

1. **Spawn / Entry**
   - Appears just above top edge.
   - Short entrance animation:
     - Scale from 0.7 → 1.0
     - Quick glow pulse or flicker
   - Some types (mines, drones) may “warp in” with distortion shader.

2. **Idle / Falling Loop**
   - Continuous motion:
     - Vertical fall with level‑based speed.
     - Small oscillation/wobble in rotation or position.
     - Subtle scale/alpha breathing or shader effect.
   - For drones, small lateral zig‑zag to increase difficulty.

3. **Tap / Hit Reaction**
   - GOOD:
     - Rapid scale up + fade, color shift to white, small particle burst.
   - BAD:
     - Violent burst, screen feedback (flash, shake, color overlay).
   - SPECIAL:
     - Stronger, more satisfying effect with distinct colors and unique audio cues.

4. **Miss / Despawn**
   - GOOD:
     - Fade out while streaking downward; sometimes breaks into fragments.
   - BAD:
     - Usually fade quickly with small puff, no penalty, or small “passive” effect.
   - OPTIONAL: For specific hazards, reaching bottom can trigger mild screen SFX (e.g., background flicker) but **no extra life loss** to keep rules clear.

**Sprite generation rule:**  
For each object’s animation state, individual frames should be generated with **slightly varied prompts or parameters** to create natural motion (e.g., variation of glow intensity, shard orientation, plasma swirl pattern). Avoid reusing identical frames.

---

## 9. Level & Difficulty Design

- **Infinite progression**, grouped into named **Sectors** (visual + difficulty theme).

Example sectors:

1. **Sector 1 – Quiet Orbit**
   - Objects: Basic GOOD (Stellar Shard, Plasma Orb, Cosmic Coin), simple BAD (Corrupted Asteroid).
   - Low spawn rate, slow fall, no lateral movement.

2. **Sector 2 – Debris Field**
   - Adds: Nano Satellite, Comet Chunk, Radiation Barrel.
   - Slightly faster fall, occasional short bursts of objects.

3. **Sector 3 – Plasma Drift**
   - Adds: Quantum Crystal, Aurora Seed, EMP Spike.
   - Introduces small lateral motion and early patterns (waves).

4. **Sector 4 – Rogue Skies**
   - Adds: Rogue Drone, Glitch Cube, Gravity Cube.
   - Mixed objects, more BAD density.

5. **Sector 5 – Toxic Storm**
   - Adds: Toxic Spore Pod, Ice Shard Cluster.
   - Visibility and slowdown hazards start appearing.

6. **Sector 6+ – Deep Void**
   - Full set of objects unlocked.
   - Rapid spawn waves, unpredictable pattern mixes, frequent BAD clusters.

For each level inside sectors:

- Parameters:
  - Base fall speed
  - Spawn interval range
  - Max simultaneous objects
  - Chance per object type (weighted)
  - Chance for patterns (lanes, clusters, alternating GOOD/BAD, fake‑out patterns)
- Level‑up:
  - Slightly faster base speed and spawn
  - Introduce one or two new objects
  - Adjust background parallax speed and color subtly.

---

## 10. Scoring, Lives & Combo System

- **Score per GOOD object:**
  - Common: 50–75
  - Uncommon: 100–150
  - Rare / Special: 200–500
- **Combo:**
  - Consecutive GOOD collects without life loss or BAD taps.
  - Combo increase: comboCount += 1 on each GOOD collect.
  - On miss/BAD tap: combo reset to 0.

- **Multiplier:**
  - `multiplier = 1.0 + floor(comboCount / 10) * 0.5` (capped, e.g., at x5).
  - Score gain: `baseScore * multiplier`.

- **Lives:**
  - Start with 3.
  - Miss GOOD: −1 life.
  - Tap BAD: −1 life (or more for particularly nasty hazards like Time Bomb).
  - Shield Core can increase life up to max (e.g., 5).
- **Game Over:**
  - When lives reach 0: slow‑motion + fade + Game Over overlay.

- **Additional bonuses:**
  - **Perfect streak:** Number of GOOD collected in a row within a level threshold grants bonus.
  - **Sector clear bonus:** On reaching certain level milestones.

---

## 11. Audio & Haptics

- **Music:**
  - One main looping track per Sector group or at least 2–3 variations.
  - Futuristic, ambient, with subtle rhythmic pulse.
  - Cross‑fade when changing sectors to avoid abrupt changes.

- **SFX:**
  - Tap GOOD: soft, bright chime variations.
  - Tap BAD: harsher, lower‑pitched hit.
  - Level up: rising arpeggio.
  - Powerup: distinct, memorable sound.
  - Game Over: short descending motif.
- Use small variations (randomized pitch, alternate samples) to avoid repetition.

- **Haptics:**
  - Light impact on GOOD collect.
  - Medium impact on BAD tap / life loss.
  - Slight rumble/pulse for Game Over and big powerups.
  - All haptics toggleable in Settings.

---

## 12. Accessibility & Options

- **Colorblind mode:**
  - Alternate palettes for GOOD/BAD to rely on shape and iconography, not just color.
- **Reduce Motion:**
  - Reduced background parallax and lower particle count.
  - Simpler spawn/collect animations while preserving core feedback.
- **Audio controls:**
  - Separate sliders for music and SFX.
- **High contrast HUD option.**

---

## 13. Data & Persistence

- **Local storage only:**
  - High score
  - Best level reached
  - Settings (audio, haptics, accessibility)
- Use `UserDefaults` or small local plist/JSON; no networking.

---

## 14. Performance & Quality Constraints

- Maintain **60 FPS** under typical load:
  - Limit simultaneous objects and particle emitters.
  - Use texture atlases when using bitmap sprites.
  - Avoid complex physics; manually manage vertical movement unless necessary.
- Use **adaptive layout**:
  - HUD scaled via SwiftUI with relative sizing and safe area insets.
  - SpriteKit scene uses fixed logical coordinate system (e.g., 750x1334) with aspect scaling.

---

## 15. Non‑Functional Requirements

- No ads, tracking, or online services.
- Code must be clean, modular, and testable:
  - MVVM for game state and menus.
  - Clear separation: SwiftUI views vs. SpriteKit gameplay.
- Project prepared for future extensions:
  - Additional object types
  - New sectors and modes (e.g., time attack) without major refactors.
