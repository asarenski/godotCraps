# godotCraps Agent Guide

A Godot 4.4 craps dice game. GDScript only, GL Compatibility renderer, web-export target.

## Commands

```sh
npm run deploy   # publish build/ to GitHub Pages via gh-pages
```

No tests, lint, or CI exist.

## Architecture

**Main scene**: `src/scenes/main/main.tscn` → four sibling nodes under `main`:
- `Start` — title screen (CanvasLayer)
- `HUD` — game UI, bet buttons, results (CanvasLayer)
- `DiceRoller` — creates/manages D6 dice in a SubViewport (3D, RigidBody3D)
- `StateManager` — state machine controller

**State machine** (`src/state/`):
States are short-lived `Node` children of `StateManager`. On each transition, the previous state is `queue_free()`'d and a new state is instantiated and `add_child()`'d. Each state receives a `change_state` Callable and calls it to trigger the next transition.

```
ComeOutBettingState → RollingState → EndRoundState (win/lose) → ComeOutBettingState
                                   → PointState → RollingState → ...
```

State classes: `State` (base) → `ComeOutBettingState`, `RollingState`, `PointState`, `EndRoundState`. The `StateFactory` enum maps names to classes.

**Important conventions**:
- Cross-node references use `$"../SiblingName"` paths from the main scene root
- `.tscn` files use UID-based resource references (not path strings)
- `Dice` base class is `RigidBody3D`; `D6Dice` extends it. Only D6 dice exist
- `DiceRoller.quick_roll()` bypasses physics with random values; `show_face()` animates rotation via tweens

## Build/Export

- Web export preset outputs to `build/index.html` (gitignored)
- Only renderer: `gl_compatibility`
- Viewport: 480×720, `canvas_items` stretch mode
- `.godot/` and `build/` are gitignored
- The `package.json` exists solely for the `gh-pages` deploy script
