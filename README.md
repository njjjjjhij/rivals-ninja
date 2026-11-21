# Ninja / Rivals

A single-file, mobile-first cheat interface for **Roblox Rivals**, built for Delta and other executors. Dark wclient-style panels, a draggable side icon that closes the UI, aimbot, ESP, movement and a client-side skin unlocker.

Feature set is inspired by the public Kiciahook / Duck Hub Rivals scripts. All code here is written from scratch - none is copied.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/njjjjjhij/rivals-ninja/main/RivalsClient.lua"))()
```

Tap the round **N** icon on the right edge of your screen to hide or show the UI. Drag it anywhere; it snaps to the screen edge.

## Features (60+)

### Aimbot
- Aimbot with Always / Hold RMB / Hold Q activation
- FOV circle and FOV slider (10-180 degrees)
- Smoothness, max turn speed, deadzone
- Target selection: Head / Body / Nearest
- Prediction and jitter filter
- Instant lock and first-person lock
- Wall check and team check
- Sticky target (keeps the same enemy)
- Auto fire (fires only when on target)
- Auto scope (zooms while locked)
- Hit marker
- Kill notifier
- Target HUD (name, HP, distance)

### Ragebot
- Instant snap with auto fire
- FOV, target part, prediction
- Wall check, team check, sticky target

### Triggerbot
- Range and delay
- Team check
- Raycast + VirtualUser / VirtualInputManager fallbacks

### ESP
- Master toggle, boxes, box fill, health bars
- Names and distance
- Tracers
- Chams (Highlight)
- Skeleton (R15 and R6)
- Head dots
- Off-screen arrows
- Pickup / weapon ESP
- Max distance, team check, hide knocked

### Movement
- Walk speed
- Jump power
- Infinite jump
- Auto jump
- Fly with speed control (Space / LeftControl for up and down)
- Noclip
- Camera FOV

### Visuals & HUD
- Fullbright
- No fog
- Custom crosshair with length slider
- Watermark with FPS, ping and player count
- Clock
- Player count
- Coordinates, FPS, ping and target readout
- Live active-feature list

### Skin Unlocker (client-side)
- 8 skin colors: Cyan, Gold, Crimson, Violet, Emerald, Ice, Pink, White
- Rainbow cycling
- 6 materials: Neon, ForceField, Glass, Metal, SmoothPlastic, Plastic
- Repaints tools, camera viewmodel and workspace weapon models, then restores on disable

### Interface
- Draggable, collapsible windows
- Side **N** icon hides/shows the UI and snaps to the edge
- Insert toggles the UI
- RightShift unloads everything cleanly

## Controls

| Input | Action |
| --- | --- |
| Tap feature name | Toggle feature |
| Tap `+` | Open settings |
| Drag window header | Move window |
| Tap `-` | Collapse window |
| Tap N icon | Hide / show UI |
| Insert | Hide / show UI |
| RightShift | Unload |

## Honest limits

- Everything here is **client-side**. The game server still decides hit registration, ammo, movement correction and inventory.
- There is **no anti-cheat bypass** in this script. Camera and input changes like these are detectable; use an alt.
- The Skin Unlocker is a visual skin applier for your own viewmodel - it does not grant real Rivals inventory skins.
- Silent aim, rapid fire, no-spread and no-recoil are not included because they cannot be done reliably from a client script without game-specific remote hooks; fake toggles were left out on purpose.
- Movement features (speed, fly, noclip) work locally and may be corrected or punished by the server.

## Disclaimer

For educational and private-server use. Using cheats in public matches breaks Roblox's rules and can get your account banned. You are responsible for how you use this.
