# Hilix / Rivals

A single-file, mobile-first cheat client for **Roblox Rivals**, built for Delta and other executors. The menu is one dark Sleepy.gg-style panel with a red `hilix.gg` wordmark, top tabs, a left module rail, and compact checkbox columns.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/njjjjjhij/rivals-ninja/main/RivalsClient.lua"))()
```

## Modules

Every module is its own page and tab — nothing is bundled into one mixed list.

- **Aim** — sticky aimbot, FOV up to 360°, smoothness, max turn, prediction, jitter filter, deadzone, curve (exponential / linear / spring), priority (crosshair / distance / low HP), head-body-nearest, aim height offset, lock delay, switch delay, max distance, wall and team checks, ignore knocked, auto fire with delay, auto scope, instant lock, first person, FOV circle, lock line, target dot, hit marker, kill notify, target HUD.
- **Rage** — 360° FOV snap, instant or smooth snap, sticky target, switch delay, fire rate, auto fire, auto scope, prediction, max distance, wall / team / knocked filters.
- **Trigger** — crosshair ray or FOV mode, FOV size, range, max distance, delay, hit chance, burst shots, wall / team / knocked filters.
- **ESP** — boxes or corner boxes, fill, health bar and health text, names (display name / username / both), distance, text size, opacity, tracers with bottom or center origin, team colors, chams with adjustable fill, R15/R6 skeleton with bone thickness, head dots, off-screen arrows with size, pickup ESP, distance limit and filters.
- **Radar** — rotating minimap with range, size, opacity, dot size and optional names.
- **Logs** — hit log, kill feed, fade duration, line limit, clear button.
- **Movement** — walk speed, jump power, infinite jump, auto jump, fly with camera or horizontal mode and speed, noclip, camera FOV, camera distance, hip height, gravity.
- **Visuals** — fullbright, no fog, disabled lighting effects, custom time and brightness, crosshair style (cross / dot / circle) with gap, thickness and length, coords, watermark, clock, player count, UI scale, panel fade and icon size.
- **Skins** — client-side viewmodel/tool repaint with 8 colors, rainbow speed, 6 materials, restores on disable.
- **Config** — loadstring copy, module panic button, key reference, version.

That is 149 toggles, sliders and option cyclers (156 controls including action buttons), every one wired to real client-side behavior.

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

- Everything runs **client-side**. The server still decides hit registration, ammo, movement correction and inventory.
- There is **no anti-cheat bypass**. Camera and input changes are detectable; use an alt.
- The Skin Unlocker is a visual repaint, not an inventory unlock.
- Silent aim, rapid fire, no-spread and no-recoil are not included because they cannot be done reliably client-side without game-specific remote hooks.
- Speed, fly, gravity and noclip work locally and may be corrected by the server.

## Disclaimer

For educational and private-server use. Using cheats in public matches breaks Roblox's rules and can get your account banned. You are responsible for how you use this.
