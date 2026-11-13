---
name: windows-fps-booster
description: Diagnose and fix low FPS, FPS drops and stutter in PC games on Windows 10/11. Scans hardware and settings read-only (RAM speed/XMP, single vs dual channel, monitor refresh rate, power plan, GPU scheduling, games installed on HDD, low disk space, startup apps, overlays, Memory Integrity, driver/BIOS age), ranks the fixes by real impact, applies only safe and reversible Windows tweaks with a backup, and walks the user through BIOS/GPU-panel steps it cannot do itself. Use when the user says "FPS boost", "FPS drop", "stutter", "oyun kasıyor", "FPS düşüyor", "oyunlarda performans", "bilgisayarı oyun için optimize et", "game lag" (rendering, not network ping), or asks why games run badly on their Windows PC.
---

# Windows FPS Booster

Goal: more average FPS and fewer drops (better 1% lows) — with evidence, not placebo tweak packs.

Core principle: **the biggest wins are almost always hardware configuration** (RAM in single channel or running below its rated speed, monitor left at 60 Hz, game on a hard disk). Registry "tweaks" are worth little. Rank honestly.

## Workflow

### 1. Diagnose (read-only, no permission needed)

Run the bundled scan and read its whole output:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "<skill-dir>/scripts/diagnose.ps1"
```

Ask the user (once, briefly) which games they play and whether drops happen everywhere or in specific moments (team fights, loading new areas, streaming). Loading-related stutter points to storage/RAM; constant low FPS points to GPU settings or CPU limits.

### 2. Interpret — use `references/findings.md`

It maps each scan field to a verdict, an expected impact and the fix. Build a ranked list: **High / Medium / Low impact**, and for each say *who* does it (Claude, the user in Windows, the user in BIOS, or a purchase).

Present the list to the user in their language before changing anything. Keep it short: what was found, why it matters, what you will do.

### 3. Apply safe tweaks (only after the user agrees)

```powershell
# Shows what it would do, changes nothing:
powershell -NoProfile -ExecutionPolicy Bypass -File "<skill-dir>/scripts/apply-tweaks.ps1" -WhatIf
# Apply chosen parts:
powershell -NoProfile -ExecutionPolicy Bypass -File "<skill-dir>/scripts/apply-tweaks.ps1" -HighPerformancePlan -DisableStartup "OneDrive","Teams"
```

Switches: `-HighPerformancePlan`, `-DisableStartup <names>` (names exactly as the scan lists them), `-EnableHAGS` (needs admin), `-EnableGameMode`. Every run first writes a backup to `Desktop\fps-booster-backup\<timestamp>`; `scripts/restore.ps1 -BackupDir <dir>` reverts it.

If the session is not elevated, skip admin-only items and give the user the Settings-app path instead (see `references/manual-steps.md`).

### 4. Guide the manual steps

From `references/manual-steps.md`, give only the steps that apply to this machine, with the exact menu path for their motherboard vendor / GPU vendor. Typical: enable XMP/EXPO in BIOS, set monitor refresh rate, GPU control panel settings, turn off the GPU overlay, move a game to the SSD.

### 5. Verify

- Re-run `diagnose.ps1` after reboots / BIOS changes and compare (e.g. RAM `ConfiguredClockSpeed` now equals the rated speed).
- Ask the user to measure the same scene before and after (FPS and 1% low) with an in-game counter or the GPU vendor's overlay, then turn the overlay off again.
- After enabling XMP: if the PC fails to boot or blue-screens, the board usually reverts after 2–3 failed boots; otherwise clear CMOS. Suggest a BIOS update if XMP is unstable on an old BIOS.

## Hard rules

- Never disable Windows Defender, Windows Update, the firewall, or anti-cheat drivers (Vanguard, EasyAntiCheat, BattlEye, FACEIT).
- Never run third-party "debloat"/"optimizer" scripts, mass-disable services, or edit undocumented registry keys (e.g. `NetworkThrottlingIndex`, `Win32PrioritySeparation`, TCP tweaks). They do little and break things.
- No overclocking/undervolting, no BIOS flashing done by Claude, no driver uninstall with DDU unless the user explicitly asks and understands it.
- Only use the reversible changes in `apply-tweaks.ps1`; always back up first.
- Do not uninstall the user's apps — only stop them from auto-starting.
- Recommend hardware purchases only when the scan proves the bottleneck (e.g. one RAM stick → buy a matching second stick), with a rough expected gain, not a shopping list.
