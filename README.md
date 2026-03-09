# Rat

A desktop pet rat for macOS. It lives on your screen as a tiny pixel-art rat that walks, sleeps, eats, climbs screen edges, reacts to your cursor, and can be picked up and dropped.

![macOS 14+](https://img.shields.io/badge/macOS-14%2B-blue) ![Swift](https://img.shields.io/badge/Swift-5-orange) ![No Xcode Required](https://img.shields.io/badge/Xcode-not%20required-green)

## Features

- Walks along the bottom of your screen
- Reacts to your cursor — sometimes follows, sometimes flees
- Drag and drop with gravity and bouncing
- Climbs screen edges
- Sleeps when tired, eats when hungry
- Energy and hunger system that influences behavior
- Menu bar icon with Feed / Sleep controls
- Right-click the rat to see stats
- Uses a bundled reference sprite to match the rat artwork exactly

## Build & Run

No Xcode project required. Just run:

```bash
./build.sh
open Rat.app
```

Requires Swift and targets `arm64-apple-macos14.0`.

## Usage

The rat appears at the bottom-center of your screen and starts doing its thing autonomously.

| Action | How |
|---|---|
| Pick up | Click and drag the rat |
| Drop | Release the mouse button |
| Feed | Right-click → Feed, or menu bar → Feed |
| Sleep / Wake | Right-click → Sleep, or menu bar → Sleep / Wake |
| See stats | Right-click the rat |
| Quit | Menu bar → Quit |

The rat runs as an `LSUIElement` app — it appears in your menu bar but not in the Dock.

## Project Structure

```
Rat/
├── App/                  # Entry point and AppDelegate
├── Model/                # RatPet (state) and PetConfig (constants)
├── StateMachine/         # State machine and PetState protocol
│   └── States/           # Idle, Walking, Sleeping, Eating, Climbing,
│                         # Dragged, Falling, CursorInteract
├── Animation/            # AnimationSystem (game loop), AnimationController,
│                         # AnimationSequence, SpriteSheet/SpriteGenerator
├── Physics/              # ScreenBounds, Movement
├── Interaction/          # MouseTracker, CursorBehavior
├── Views/                # RatView (NSView + CALayer rendering)
├── Window/               # PetWindow (borderless transparent window)
└── Menu/                 # StatusBarController, ContextMenuBuilder
```
