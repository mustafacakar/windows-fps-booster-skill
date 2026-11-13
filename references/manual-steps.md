# Manual steps (give only what applies)

## Enter BIOS
Restart and tap the key while the logo shows: **Del** (Gigabyte, MSI, ASRock, most ASUS), **F2** (some ASUS/laptops). Many boards open an "Easy Mode" first — **F7** (ASUS/MSI) or **F2** (Gigabyte) switches to Advanced.

## Enable XMP / EXPO / DOCP
| Vendor | Where |
|---|---|
| Gigabyte | Easy Mode: **X.M.P.** → Profile1. Advanced: **Tweaker** (older BIOS: **M.I.T.**) → Extreme Memory Profile (X.M.P.) → Profile1 |
| MSI | Main screen top-left **A-XMP** / **XMP** / **EXPO** toggle → Profile 1 |
| ASUS | Ai Tweaker → Ai Overclock Tuner → **D.O.C.P.** / **XMP I** / **EXPO I** |
| ASRock | OC Tweaker → DRAM Configuration → Load XMP Setting → XMP 2.0 Profile 1 |
Save with **F10** → Yes. Then re-run the scan to confirm the new speed.
If it does not boot: wait — boards usually revert after 2–3 failed attempts. Otherwise clear CMOS (jumper or remove battery 1 min with PC unplugged).

## Monitor refresh rate
Settings → System → Display → (select monitor) → Advanced display → **Choose a refresh rate**. If the max is missing: use DisplayPort or an HDMI 2.0 cable, and check the monitor's own OSD (some have "overclock"/"FreeSync" options that unlock the highest rate).

## Hardware-accelerated GPU scheduling (HAGS)
Settings → System → Display → Graphics → Change default graphics settings → **Hardware-accelerated GPU scheduling** ON → reboot.

## Game Mode / background recording
Settings → Gaming → Game Mode ON. Settings → Gaming → Captures → Record what happened → OFF.

## NVIDIA
- **NVIDIA Control Panel** → Manage 3D settings → Global: Power management mode **Prefer maximum performance**, Low latency mode **On** (or Ultra if CPU-bound and you cap FPS), Texture filtering – Quality **High performance**, Max frame rate: off or refresh rate + 3 when using G-Sync/FreeSync.
- **NVIDIA App** → Settings → Features → **NVIDIA Overlay** OFF (Turkish UI translates it as "NVIDIA yer paylaşımı"). Also consider turning off "Automatically optimize newly added games".
- Old GeForce Experience: Settings → General → In-game overlay OFF.

## AMD
**AMD Software: Adrenalin** → Gaming → Graphics: Radeon Anti-Lag ON, Radeon Chill OFF, Radeon Boost optional. Settings → Preferences → In-Game Overlay OFF. Settings → Hotkeys: disable if unused.

## Intel Arc
Intel Graphics Software → turn off overlay, keep driver current (big gains per release on Arc).

## Other overlays
Discord: User Settings → Game Overlay → off. Xbox Game Bar: Settings → Gaming → Xbox Game Bar off. Steam: Settings → In Game → overlay off (optional).

## Move a game to the SSD
- Steam: Library → right-click game → Properties → Installed Files → **Move install folder**.
- Epic: no move button — move the folder, then "Install" to the new location and it verifies instead of downloading.
- Riot (LoL/Valorant): uninstall + reinstall to the SSD path, or move the folder and point the Riot Client to it.
- Battle.net / EA app: game settings → change install location / "Locate game".

## Free up the system SSD
Start → **Disk Cleanup** → Clean up system files (Windows Update cleanup, Delivery Optimization). Settings → System → Storage → Temporary files. Move Downloads/Videos to the HDD.
