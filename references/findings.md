# Interpreting the scan

Impact estimates are typical ranges for CPU-bound esports titles (LoL, Valorant, CS2, Fortnite) and open-world games on mid-range PCs. State them as "typically", never as a promise.

| Scan field | Bad sign | Impact | Fix | Who |
|---|---|---|---|---|
| `RAM modules` | 1 module (single channel) | **High** — 15–40 % avg FPS, much better 1 % lows on Ryzen and modern Intel | Buy a second identical stick (same part number) and put both in the slots the board manual marks for dual channel (usually A2+B2) | Purchase |
| `RAM modules` | 2 modules in same-channel slots (e.g. A1+A2) | High | Move to A2+B2 per manual | User |
| `RAM configured MHz` vs part number | DDR4 at 2133/2400/2666 while the part number says 3000/3200/3600 (e.g. `KHX3000…`, `…3200C16…`, `F4-3600…`); DDR5 at 4800 while rated 6000 | **High** on Ryzen (Infinity Fabric follows RAM clock), Medium on Intel — ~10–15 % | Enable XMP (Intel/Gigabyte/MSI/ASUS) or EXPO/DOCP (AMD) in BIOS | User (BIOS) |
| `Refresh` current < max | 60 Hz while monitor supports 75/144/165 | **High** for perceived smoothness | Settings → Display → Advanced display → Refresh rate; check cable (HDMI 1.4 may cap at 60 Hz at 1080p144 — use DisplayPort) | User / Claude can explain |
| `Game on HDD` | Game folder on a disk with MediaType HDD | **High** for load stutter / texture pop-in, none for avg FPS | Move game to SSD (launchers have "move/locate" options) | User |
| `Free space` | System SSD < 15 % free | Medium — SSD slows, pagefile pressure | Disk Cleanup (incl. system files), clear `%TEMP%`, move media to HDD | User / Claude |
| `Power plan` | Balanced / Power saver on a desktop | Low–Medium (helps clock ramp-up, small 1 % low gain) | High performance plan | Claude |
| `HAGS` | HwSchMode not 2 on GTX 10xx+/RX 5000+ | Low, sometimes helps 1 % lows; required for DLSS Frame Generation | Settings → Display → Graphics → Hardware-accelerated GPU scheduling | Claude (admin) / User |
| `Game Mode` | AutoGameModeEnabled = 0 | Low | Turn on | Claude |
| `Memory Integrity / VBS` | VBS running | Medium on older CPUs (5–10 %) | Explain trade-off (security feature). Only suggest turning off on a dedicated gaming PC, user decides: Windows Security → Device security → Core isolation | User decides |
| `GameDVR / background recording` | Enabled | Low–Medium | Settings → Gaming → Captures → background recording off | Claude/User |
| `Startup apps` | Many launchers/sync/chat clients | Low for FPS, Medium for drops caused by background updates/sync | Disable auto-start (not uninstall) | Claude |
| `Overlays running` | NVIDIA Overlay, Discord overlay, Xbox Game Bar, Overwolf, RGB suites | Low, can cause stutter/hitches | Turn off in each app's settings | User |
| `GPU driver date` | Older than ~6 months | Low–Medium for new games | Update from vendor app/site (clean install option) | User |
| `BIOS date` | Older than ~2 years on AM4/AM5 | Medium when XMP is unstable; better RAM compatibility | Update from board vendor site — only if needed; never during storms/without UPS concerns explained | User |
| `Pagefile` | Disabled or tiny (< 4 GB) with ≤ 16 GB RAM | Medium — crashes/stutter | Set to "System managed" | User |
| `RAM total` | ≤ 8 GB | High for modern games | Upgrade | Purchase |
| `CPU/GPU load` (if user runs a game) | GPU < 90 % with low FPS → CPU-bound; GPU 99 % → lower graphics settings | — | CPU-bound: RAM fixes above, close background apps, lower view distance/crowd settings. GPU-bound: lower resolution scale, shadows, use DLSS/FSR | User |

## Things that are NOT worth recommending

"Ultimate Performance" power plan on desktops (≈ High performance), disabling SysMain/Superfetch, timer-resolution tools, MSI-mode utilities, TCP/Nagle tweaks (network, not FPS), `bcdedit` changes, disabling Spectre mitigations, "game booster" apps. If the user asks about them, explain briefly why they are skipped.
