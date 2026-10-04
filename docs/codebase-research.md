# Codebase Research: godotCraps

A snapshot of the codebase as it exists today: the intended game design, the actual architecture, and the Godot 4.7 APIs the code relies on (cross-checked against official docs).

> Updated after the architecture deepening pass (2026-10-04). See `docs/work-log.md` for the change history.

---

## 1. Game Concept (intended design)

Source: `docs/vision.md`.

godotCraps is a **dice-control roguelite** built around a modified version of craps. The central fantasy is becoming a highly specialized dice thrower whose build, preparation, and execution influence the physical behavior of the dice (`docs/vision.md:11`).

### Core terminology (`docs/vision.md:45-88`)

- **Run** — a complete roguelite attempt; ends on a failed bankroll gate, bankruptcy, or reaching the final goal (`docs/vision.md:49-53`).
- **Set** — a survival streak around one Pass or Don't Pass commitment; the player locks a side and wagers, then plays multiple point cycles until the side loses (`docs/vision.md:55-65`).
- **Point Cycle** — come-out roll → point established → throws until resolution → optional wager increase (`docs/vision.md:67-75`).
- **Throw** — one physical roll of two dice, influenced by orientation, execution, attributes, cards, and bounded randomness (`docs/vision.md:77-81`).
- **Bankroll Gate** — a required bankroll total checked after a group of sets; passing grants a card, failing ends the run (`docs/vision.md:83-87`).

### Core loop (`docs/vision.md:91-141`)

Choose side → place wager → establish point → resolve point cycle (win: set continues, optional wager double; lose: set ends, settle wager) → next set or bankroll gate.

### Run progression (`docs/vision.md:145-179`)

Runs are divided into groups of three sets. Preliminary gates: 3 sets → 150 bankroll, 6 → 1,000, 9 → 3,000 (`docs/vision.md:151-159`). Each gate grants one power-up card.

### Dice throw system (`docs/vision.md:208-270`)

Four influence layers: (1) dice orientation, (2) skill-based throw execution, (3) build/card modifiers, (4) bounded randomness.

### Deckbuilding (`docs/vision.md:274-349`)

Cards across categories: Axis Control, Paired Dice, Total Specialization, Throw Technique, Variance/Luck. Player level caps the maximum wager (`docs/vision.md:181-204`).

---

## 2. Project Configuration

Source: `project.godot`, `export_presets.cfg`, `package.json`.

- Engine features: `PackedStringArray("4.7", "GL Compatibility")` (`project.godot:19`).
- `[animation]` section enables `compatibility/default_parent_skeleton_in_mesh_instance_3d=true` (`project.godot:11-13`), a 4.7 migration flag for the `d6.glb` mesh.
- Renderer: `gl_compatibility` (desktop and mobile) (`project.godot:35-36`).
- Viewport `480×720`, stretch mode `canvas_items`, handheld orientation portrait (`project.godot:24-27`).
- Main scene resolved by UID `uid://cnb5a5dss37ra` (`project.godot:18`), which matches `main.tscn`'s `uid="uid://cnb5a5dss37ra"` (`src/scenes/main/main.tscn:1`).
- Blender import disabled; ETC2/ASTC texture compression enabled (`project.godot:31-37`).
- Single Web export preset → `build/index.html`, `script_export_mode=2` (`export_presets.cfg:1-19`).
- `package.json` exists solely for the `gh-pages -d build` deploy script (`package.json:16-20`; `AGENTS.md:15-17`).

---

## 3. Code Architecture

### 3.1 Main scene node tree

Source: `src/scenes/main/main.tscn`.

```
main (Node)                                     main.tscn:9
├── Start (CanvasLayer)          [start.gd]     main.tscn:11
│   ├── Message (Label)
│   └── StartButton (Button)
├── HUD (CanvasLayer)            [hud.gd]       main.tscn:49
│   ├── BetButtons (HBoxContainer)              main.tscn:52
│   │   ├── Bet5 / Bet10 / Bet25 / ClearBet (Button)
│   ├── RollButton (Button)                     main.tscn:89
│   ├── HUDTop (BoxContainer)                   main.tscn:105
│   │   ├── Bankroll (Label)
│   │   ├── Bet (Label)
│   │   ├── Phase (Label)
│   │   └── Timer (wait_time 0.25)              main.tscn:135-136
│   ├── Results (BoxContainer)                  main.tscn:138
│   │   ├── DiceResult (Label)
│   │   └── RoundResult (Label)
│   └── SubViewportContainer                    main.tscn:164
│       └── RollViewPort (SubViewport)          main.tscn:176
│           ├── Camera3D                         main.tscn:181
│           └── DirectionalLight3D               main.tscn:185
├── DiceRoller (Node)            [dice_roller.gd] main.tscn:188
└── StateManager (Node)          [state_manager.gd] main.tscn:192
```

Four sibling nodes under `main`, matching `AGENTS.md:23-27`. The `SubViewportContainer` uses `top_level = true` and holds a `SubViewport` (`size = Vector2i(480, 128)`, `render_target_update_mode = 4`) with a `Camera3D` and `DirectionalLight3D` inside (`main.tscn:164-186`). Signal connections are declared in-scene (`main.tscn:196-198`): StartButton→`Start._on_start_button_pressed`, RollButton→`HUD._on_roll_button_pressed`, Timer→`HUD._on_timer_timeout`.

### 3.2 State machine

Source: `src/state/`.

The `State` base class is a `Node` (`src/state/state.gd:1-3`) holding progression state plus injected collaborators:

- `GamePhase { COME_OUT, POINT, GAME_OVER }` and `BetType { PASS_LINE }` enums (`state.gd:6-15`).
- `point` — the only copy-forwarded game state (`state.gd:18`).
- Collaborators: `change_state: Callable`, `previous_state: State`, `view: Node`, `bankroll: Bankroll`, `dice_roller: DiceRoller` (`state.gd:20-24`).
- `setup(change_state, previous_state, view, bankroll, dice_roller, _params)` copies only `point` forward from the previous state (`state.gd:26-35`).

Money and rules live in two modules injected into every state:

**`Bankroll`** (`src/state/bankroll.gd`) — `class_name Bankroll extends RefCounted`:

- `balance` (total money) and `wager` (committed wager) (`bankroll.gd:5-6`).
- `place_wager(amount) -> bool` (rejects if `balance < amount`), `clear_wager() -> int`, `settle(won) -> int` (win pays `wager * 2`) (`bankroll.gd:12-32`).

**`CrapsRules`** (`src/state/craps_rules.gd`) — pure resolution, no scene graph:

- `Outcome { WIN, LOSE, ESTABLISH_POINT, CONTINUE }` (`craps_rules.gd:3-8`).
- `static resolve(roll, point) -> int` — come-out 7/11 → WIN, 2/3/12 → LOSE, else ESTABLISH_POINT; point phase: hit point → WIN, 7 → LOSE, else CONTINUE (`craps_rules.gd:10-24`).

Concrete states (`src/state/`):

- **`ComeOutBettingState`** — clears `point`, shows come-out phase via `view`, enables betting, connects `view.bet_increased/bet_cleared/roll_requested`; shows GAME OVER if balance is 0 (`comeout_betting_state.gd:5-17`). Wager add/clear via `bankroll.place_wager/clear_wager` (`comeout_betting_state.gd:19-27`); transitions to `ROLLING` if wager > 0 (`comeout_betting_state.gd:29-31`).
- **`PointState`** — shows point phase via `view`, disables betting, connects `roll_requested`; transitions to `ROLLING` if wager > 0 (`point_state.gd:5-14`).
- **`RollingState`** — connects `dice_roller.roll_complete` and calls `dice_roller.quick_roll()` on entry; on completion, `CrapsRules.resolve` maps the outcome to the next state (`rolling_state.gd:5-20`).
- **`EndRoundState`** — `bankroll.settle(win)` and shows the result via `view`, then immediately transitions back to `COMEOUT_BETTING` (`end_round_state.gd:10-22`).

**`StateFactory`** maps an enum to classes (`state_factory.gd:14-20`):

```
COMEOUT_BETTING → ComeOutBettingState
POINT           → PointState
ROLLING         → RollingState
END_ROUND       → EndRoundState
```

**`StateManager`** drives transitions (`state_manager.gd:20-27`):

```gdscript
func change_state(new_state_name, params = null):
    var previous_state = state
    if previous_state != null:
        previous_state.queue_free()
    state = state_factory.get_state(new_state_name).new()
    add_child(state)
    state.setup(Callable(self, 'change_state'), previous_state, view, bankroll, dice_roller, params)
```

Dependencies are injectable: `_ready` resolves `view`, `dice_roller`, and `bankroll` from siblings only if not already set (`state_manager.gd:10-18`). The headless test exploits this to inject a `TestView` and a `FakeDiceRoller`.

Actual state flow:

```
ComeOutBettingState → RollingState → EndRoundState (win/lose) → ComeOutBettingState
                                   → PointState → RollingState → (PointState | EndRoundState)
```

This matches the diagram in `AGENTS.md:32-35`.

### 3.3 Dice system

Source: `src/scenes/dice_roller/`.

**`Dice` (base)** — `class_name Dice extends RigidBody3D` (`dice.gd:1-2`).

- `@export var die_color := Color.BROWN`; `sides` dict mapping face value → local direction; `dice_size := 2.0`, `dice_density := 10.0`; `rolling`/`roll_time`; `signal roll_complete(int)` (`dice.gd:4-15`).
- `_init()` configures physics: `continuous_cd = false`, `can_sleep = true`, `gravity_scale = 10`, `freeze_mode = FREEZE_MODE_STATIC` (`dice.gd:17-21`).
- `@onready var mesh = $DiceMesh`; `_ready()` duplicates the material override, tints `albedo_color = die_color`, sets `mass = dice_density * dice_size**3`, and calls `stop()` (`dice.gd:23-29`).
- `stop()` freezes/sleeps the body and zeroes linear/angular velocity (`dice.gd:31-35`).
- `face_up_transform(value)` computes a rotation basis that brings the requested face normal to `Vector3.UP` (`dice.gd:37-47`).
- `show_face(value)` tweens `transform` to that rotation over `0.3`s, then emits `roll_complete(value)` (`dice.gd:49-60`).

**`D6Dice`** — `class_name D6Dice extends Dice`; defines the side map: `1→LEFT, 2→FORWARD, 3→DOWN, 4→UP, 5→BACK, 6→RIGHT` (`d6_dice.gd:1-13`).

**`DiceRoller`** — `class_name DiceRoller extends Node` (`dice_roller.gd:1-2`).

- Preloads `d6_dice.tscn` via `DiceScenes = {6: preload(...)}` (`dice_roller.gd:4-6`).
- `signal roll_complete(total: int, values: Array)` — carries both the total and the per-die face values; `signal roll_start()` (`dice_roller.gd:8-9`).
- `default_set` defines two dice (`red`/`yellow`, both `DARK_ORANGE`) and their positions (`dice_roller.gd:11-20`).
- `_ready()` builds `DiceDef`s and calls `add_die_to_scene()` when no dice are set (`dice_roller.gd:35-42`).
- `add_die_to_scene()` instantiates the packed scene, names it, sets `die_color` and `position`, connects each die's `roll_complete` bound to its name, and appends to `dice` (`dice_roller.gd:44-52`).
- `_on_roll_complete(number, dice_name)` aggregates per-die results into `result`; when all dice are done it emits `roll_complete(total_value, result.values())` (`dice_roller.gd:54-59`).
- `quick_roll()` — **non-physics**: picks a random face per die via `randi_range` and calls `show_faces()` (`dice_roller.gd:61-69`). Physics (mass/gravity/collision) is not used for actual rolls.
- `show_faces(faces)` resets `result`, sets `rolling = true`, and calls `show_face()` on each die (`dice_roller.gd:71-78`).

**`DiceDef`** — a `Resource` (`@icon("./icon.svg")`) with exported `name`, `color`, and `sides` (an `@export_enum("D6:6")`), plus an icon map preloading the D6 SVG (`dice_def.gd:1-11`).

**`d6_dice.tscn`** — instances `d6.glb` (script `d6_dice.gd`), with a `CollisionShape3D` (`BoxShape3D` size `2×2×2`, `margin 0.2`) and a `DiceMesh` child using a `StandardMaterial3D` with albedo + normal map (`d6_dice.tscn:8-25`).

### 3.4 UI layers

**`Start`** (`src/scenes/main/start.gd`) — `extends CanvasLayer`; defines `signal start_game`; hides itself and emits `start_game` when the button is pressed (`start.gd:1-8`).

**`HUD`** (`src/scenes/main/hud.gd`) — `extends CanvasLayer`; implements the presentation seam. Input signals `bet_increased(amount)`, `bet_cleared`, `roll_requested` (`hud.gd:3-5`).

- `_ready()` hides itself, connects bet buttons, resolves `dice_roller = $"../DiceRoller"`, connects `roll_complete`/`roll_start` and `$"../Start".start_game`, then clears results (`hud.gd:10-24`).
- View interface (called by states, not the node tree): `show_money(balance, wager)` (also flashes the bet color on wager change and drives `RollButton` visibility), `show_phase(phase, point)` (formats text + color from the `GamePhase` enum), `set_betting_enabled(bool)`, `show_round_result(text)`, `clear_results()` (`hud.gd:34-65`).
- Bet buttons emit `bet_increased` (+5/+10/+25); `ClearBet` emits `bet_cleared`; `RollButton` emits `roll_requested` (`hud.gd:82-98`).
- `_on_roll_start()` disables `RollButton`; `_on_roll_complete(total, values)` re-enables it and renders the dice result from `values` (`hud.gd:94-103`). `_last_wager` tracks the prior wager so `show_money` can derive the flash direction (`hud.gd:8`).

### 3.5 Theme & shader

- `src/themes/default_theme.tres` — a `Theme` with a `SystemFont` ("Futura"), default font size 20, `Button` and `BetButton` type-variation styleboxes (`default_theme.tres:57-70`).
- `src/scenes/dice_roller/d6_dice/highlight_blur.gdshader` — a `shader_type spatial` shader computing an animated `ALPHA` (`highlight_blur.gdshader:1-10`). It is **not referenced** by any `.tscn`/`.tres` in the project (unused asset).

### 3.6 Tests

Source: `test/`. No framework; each file is a headless `SceneTree` script run with `godot --headless --path . --script res://test/<file>.gd`.

- `bankroll_smoke.gd` — money flows: place/clear/settle, over-wager rejection.
- `craps_rules_smoke.gd` — come-out naturals, craps, point establishment, point hit, seven-out, continue.
- `state_machine_smoke.gd` — full bet → roll → resolve flow, driven through a `TestView` (records view calls) and a `FakeDiceRoller` (synchronous, programmable outcomes) injected into `StateManager`.

---

## 4. Conventions (verified in code)

- **Cross-node references** use `$"../SiblingName"` from the main-scene root: `hud.gd:18` (`$"../DiceRoller"`), `hud.gd:21` (`$"../Start"`), `state_manager.gd:12` (`$"../HUD"`).
- **UID-based resource references** in `.tscn`: `ext_resource` entries carry both `uid=` and `path=` (`main.tscn:3-7`, `d6_dice.tscn:3-6`); the main scene itself is `uid="uid://cnb5a5dss37ra"` (`main.tscn:1`).
- **Collaborator injection**: states receive `view`, `bankroll`, `dice_roller` (and the `change_state` Callable) through `setup()` (`state.gd:26-31`), rather than reaching into the HUD's node tree or copy-forwarding money/phase fields.
- **`Callable` change_state** passed into each state: `state.setup(Callable(self, 'change_state'), ...)` (`state_manager.gd:27`).
- **`queue_free()` / `add_child()` state swapping**: previous state freed, new state instantiated, added (`add_child`), then `setup()` (`state_manager.gd:21-27`). `add_child` precedes `setup` so re-entrant transitions are safe.
- **Duck-typed view seam**: `view` is typed `Node`; the HUD and the test's `TestView` both implement the five view methods and three input signals without a shared base class.
- **`@export` / `@onready`**: `die_color` (`dice.gd:4`), `dice_set` (`dice_roller.gd:26`), `DiceDef` fields (`dice_def.gd:5-7`); `mesh` (`dice.gd:23`).
- **Signal connections** both in-code (`.connect(...)`) and in-scene (`[connection ...]` blocks in `main.tscn:196-198`).
- Only **D6** dice exist; `Dice` base is `RigidBody3D` and `D6Dice` extends it (`AGENTS.md:42-43`; `d6_dice.gd:1-3`).
- `DiceRoller.quick_roll()` bypasses physics with random values; `show_face()` animates rotation via tweens (`AGENTS.md:43`; `dice_roller.gd:61-69`, `dice.gd:49-60`).

---

## 5. Verified Godot API Notes

Cross-checked against Context7 (`/websites/godotengine_en_4_7`).

### 5.1 RigidBody3D / physics

The `Dice` node is a `RigidBody3D` (`dice.gd:2`). Verified facts:

- `continuous_cd` (`bool`, default `false`) controls continuous collision detection to prevent tunneling (`class_rigidbody3d.html`).
- A rigid body that is at rest "goes to sleep"; a sleeping body acts like a static body and its forces are not calculated, waking on applied forces/collisions — the code relies on this via `sleeping = true` in `stop()` (`dice.gd:31-35`) and `can_sleep`/`freeze_mode`/`gravity_scale`/`mass` (`dice.gd:17-29`).
- The docs recommend setting velocities/physics state via `_integrate_forces()` rather than direct assignment, and note that a sleeping body's `_integrate_forces()` is not called. The code instead directly assigns `linear_velocity`/`angular_velocity` in `stop()` (`dice.gd:34-35`) — a deliberate choice since these dice are currently displayed via tween, not simulated physics.

### 5.2 SubViewport (3D rendered into UI)

The dice are shown inside a `SubViewport` (with a `Camera3D` + `DirectionalLight3D`) wrapped in a `SubViewportContainer` (`main.tscn:164-186`). Verified facts:

- A `SubViewport` is a render target; its contents are not visible in the scene and must be drawn (e.g. via a `ViewportTexture`, or — as here — a `SubViewportContainer`). Use case: "Rendering 3D objects within a 2D game" (`tutorials/rendering/viewports.html`).
- A `Camera3D` displays on its closest parent `Viewport`, so the `Camera3D` inside `RollViewPort` renders to that `SubViewport` (`tutorials/rendering/viewports.html`).
- `SubViewport.render_target_update_mode` (`UpdateMode`) controls when the sub-viewport updates as a render target (`class_subviewport.html`); the scene sets it to `4` (`main.tscn:179`).

### 5.3 Tween animation

`Dice.show_face()` animates rotation with a tween (`dice.gd:55-58`). Verified facts:

- `create_tween()` (bound to the node) returns a `Tween`; it starts automatically on the next frame and is killed when the node is freed (`class_scenetree.html`).
- `tween_property(object, property: NodePath, final_val, duration)` appends a `PropertyTweener`, interpolating a property from its current value to `final_val` over `duration` seconds (`class_tween.html`).
- `await tween.finished` resumes execution after the tween completes (`dice.gd:58`; `class_tween.html`).

### 5.4 Node lifecycle / state swapping

Not queried via Context7 (trivially standard), but documented from the code: `StateManager.change_state()` frees the previous state with `queue_free()` and instantiates the next via `StateFactory.get_state(...).new()`, then `add_child()` before `setup()` (`state_manager.gd:21-27`). Each state re-establishes its own signal connections in `setup()`, and the previous state's connections die with its node.

---

## 6. Gaps: vision.md vs. what is implemented today

The implementation is a **minimal single-round craps loop**, not yet the vision's roguelite.

| Vision (`docs/vision.md`) | Implemented today |
| --- | --- |
| Pass **and** Don't Pass side choice per set (`vision.md:93-101`) | Only Pass Line; `BetType` enum has a single `PASS_LINE` value (`state.gd:13-14`); no side choice anywhere |
| **Sets** of multiple point cycles locked to a side (`vision.md:55-65`) | No set concept; `EndRoundState` always returns to `ComeOutBettingState` after every resolution, win or lose (`end_round_state.gd:22`) |
| **Bankroll gates** every 3 sets + card selection (`vision.md:145-179`) | No gates, no cards, no deckbuilding; bankroll starts at 100 and never gates (`bankroll.gd:8`) |
| **Player level / max wager** (`vision.md:181-204`) | No level, no wager cap; any amount up to bankroll may be wagered (`bankroll.gd:12-17`) |
| **Dice orientation control** (set die faces before throw) (`vision.md:214-224`) | No orientation setup; `quick_roll()` chooses random faces (`dice_roller.gd:61-69`) |
| **Skill-based throw execution** (force/angle/spin/etc.) (`vision.md:226-242`) | Not present; only "Roll" button triggers a random roll (`hud.gd:97-98`) |
| **4-layer throw system** / build modifiers / bounded-randomness tuning (`vision.md:208-270`) | Only bounded randomness (uniform `randi_range`) exists |
| **Wager doubling / retention after a win** (`vision.md:128-141`) | Win pays `wager * 2` immediately and resets the wager to 0; no doubling (`end_round_state.gd:13-14`, `bankroll.gd:25-32`) |

The come-out resolution implemented is **standard craps** (7/11 win, 2/3/12 lose, else point) (`craps_rules.gd:10-24`), whereas vision.md explicitly defers "modified craps" come-out rules because come-out rolls should not end a set (`vision.md:118`, `vision.md:429-433`). Most of the 15 open rule questions in `vision.md:429-448` remain unanswered in code.

---

## 7. Anomalies / notes

- **Orphaned UID file**: `src/state/come_out_state.gd.uid` exists but there is no `come_out_state.gd` — evidence the class was renamed to `ComeOutBettingState` (`comeout_betting_state.gd:3`) without removing the old UID sidecar.
- **Broken `@icon` path**: `dice_def.gd:1` references `./icon.svg`, but no `icon.svg` exists in `src/scenes/dice_roller/`. (`d6_dice.gd:1`'s `@icon("./d6_dice.svg")` is valid.)
- **Unused shader**: `highlight_blur.gdshader` is not referenced by any scene or material.
- **Both dice are the same color**: `default_set` names them `red`/`yellow` but assigns `Color.DARK_ORANGE` to both (`dice_roller.gd:11-20`).
- **`BetType` enum is unused**: declared (`state.gd:13-14`) but no code branches on it yet.
- **Dice physics is scaffolding**: `RigidBody3D` physics properties (mass, gravity, freeze, collision shape) are configured but the actual roll path is random values + tween rotation (`dice_roller.gd:61-69`, `dice.gd:49-60`).

---

## Sources

- Repo: `docs/vision.md`, `docs/work-log.md`, `GLOSSARY.md`, `AGENTS.md`, `project.godot`, `export_presets.cfg`, `package.json`, all files under `src/` (GDScript, `.tscn`, `.tres`, `.gdshader`), and `test/`.
- Godot 4.7 docs via Context7, library id `/websites/godotengine_en_4_7`: `class_rigidbody3d.html`, `tutorials/physics/rigid_body.html`, `tutorials/physics/physics_introduction.html`, `tutorials/rendering/viewports.html`, `class_subviewport.html`, `class_tween.html`, `class_scenetree.html`.
