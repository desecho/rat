# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build

This is a pure Swift macOS app (no Xcode project). Build with:

```bash
./build.sh
```

This compiles all `.swift` files under `Rat/` with `swiftc`, targeting `arm64-apple-macos14.0`, and produces `Rat.app`. Run with `open Rat.app`.

There is no package manager, no test suite, and no linter configured.

## What This Is

A desktop pet rat for macOS. The rat lives as a borderless transparent window (`LSUIElement` app — no Dock icon) that floats above other windows. It walks along the bottom of the screen, reacts to the cursor, can be dragged, falls with gravity/bouncing, climbs screen edges, sleeps, eats, and plays. Sprites are loaded from bundled PNG assets under `Rat/Resources/Sprites/`.

## Architecture

**App bootstrap** — `main.swift` creates `NSApplication` manually (no storyboard/NIB). `AppDelegate` wires everything together and owns all top-level objects.

**Game loop** — `AnimationSystem` runs a 60fps `Timer` that each tick: updates the `StateMachine`, advances `AnimationController` frames, decays `RatPet` needs, then redraws the view and repositions the window.

**State machine** — `StateMachine` holds all `PetState` instances keyed by `RatStateID`. Each state implements `enter`/`exit`/`update(dt:)`. States return the next `RatStateID` to trigger a transition, or `nil` to stay. External systems can call `forceTransition(to:)`. States: idle, walking, sleeping, eating, playing, climbing, dragged, falling, cursorInteract.

**Rendering** — `SpriteSheet` loads `CGImage` frames from bundled PNG assets. `AnimationController` manages named `AnimationSequence`s and advances frame indices at `PetConfig.animationFPS`. `RatView` (an `NSView` with a `CALayer`) displays the current frame, applying transforms for facing direction and climbing rotation.

**Window** — `PetWindow` is a borderless, transparent, always-on-top `NSWindow`. Its `trackPosition(_:)` method repositions it so the sprite's bottom-center aligns with `RatPet.position` in screen coordinates.

**Model** — `RatPet` holds position, velocity, facing direction, climbing state, energy, hunger, and boredom. `PetConfig` is the single source for all tunable constants (speeds, durations, weights, thresholds).

**Interaction** — `MouseTracker` uses a global `NSEvent` monitor for mouse movement. `CursorBehavior` detects proximity and triggers `cursorInteract` state. Drag/drop is handled via `RatView` mouse event closures wired in `AppDelegate`.

**Menus** — `StatusBarController` provides a menu bar item (Feed/Play/Sleep/Climb/Quit). Right-clicking the rat shows a context menu via `ContextMenuBuilder` with energy/hunger/boredom stats.

## Key Conventions

- All tunable values live in `PetConfig` — add new constants there, not inline.
- New behaviors should be new `PetState` conformances registered in `StateMachine.init`.
- New animations need bundled `rat-<name>-<frame>.png` files in `Rat/Resources/Sprites/` and a `register()` call in `AnimationController.registerAll()`.
- Screen coordinates use macOS convention (origin at bottom-left).
