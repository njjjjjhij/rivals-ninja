# Hilix / Rivals

A single-file, mobile-first cheat client for **Roblox Rivals**, built for Delta and other executors. The menu is a single dark Sleepy.gg-style panel: red `hilix.gg` wordmark, top tabs, left nav, and compact checkbox columns. A round **H** icon on the right edge closes the UI.

Feature set is inspired by the public Kiciahook / Duck Hub Rivals scripts. All code is written from scratch - none is copied from Sleepy.gg or Kiciahook.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/njjjjjhij/rivals-ninja/main/RivalsClient.lua"))()
```

## Menu

- Single translucent panel with `hilix.gg` branding and red accents
- Top tabs: rage / visuals / misc / skins / settings
- Left nav: main / aim / esp / misc / skins / configs
- Compact checkbox rows, inline value boxes and slim sliders
- Draggable header, `x` closes the menu, round **H** side icon reopens it

## Features (60+)

### Aimbot
Aimbot, activation modes, FOV circle and slider, smoothness, max turn, deadzone, Head/Body/Nearest, prediction, jitter filter, instant lock, first-person lock, wall check, team check, sticky target, auto fire, auto scope, hit marker, kill notifier, target HUD.

### Ragebot
Instant snap, auto fire, FOV, target part, prediction, wall check, team check, sticky target.

### Triggerbot
Range, delay, team check, raycast with VirtualUser / VirtualInputManager fallbacks.

### ESP
Boxes, fill, health bars, names, distance, tracers, chams, R15/R6 skeleton, head dots, off-screen arrows, pickup ESP, max distance, team check, hide knocked.

### Movement
Walk speed, jump power, infinite jump, auto jump, fly with speed, noclip, camera FOV.

### Visuals & HUD
Fullbright, no fog, custom crosshair, watermark, clock, player count, coordinates, FPS, ping, target readout.

### Skin Unlocker (client-side)
8 skin colors, rainbow mode, 6 materials, repaints tools and viewmodels and restores on disable.

## Controls

| Input | Action |
| --- | --- |
| Tap a row | Toggle feature |
| Tap a value box | Cycle option |
| Drag a slider bar | Change value |
| Drag the header | Move the panel |
| Tap `x` | Close the menu |
| Tap H icon | Show / hide the menu |
| Insert | Show / hide the menu |
| RightShift | Unload |

## Honest limits

- Everything is **client-side**. The server still decides hit registration, ammo, movement correction and inventory.
- There is **no anti-cheat bypass**. Camera and input changes are detectable; use an alt.
- The Skin Unlocker is a visual viewmodel skin applier, not a real inventory unlock.
- Silent aim, rapid fire, no-spread and no-recoil are not included because they cannot be done reliably client-side without game-specific remote hooks.
- Speed, fly and noclip work locally and may be corrected by the server.

## Disclaimer

For educational and private-server use. Using cheats in public matches breaks Roblox's rules and can get your account banned. You are responsible for how you use this.
