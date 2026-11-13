# windows-fps-booster

A [Claude Code](https://claude.com/claude-code) / Claude Agent skill that finds out **why your games run badly on Windows** and fixes what can be fixed safely: more average FPS, fewer drops and less stutter.

No "magic registry pack". The skill scans your PC, ranks problems by real impact and tells you honestly that the biggest wins are usually things like:

- RAM running in **single channel**, or below its rated speed because **XMP/EXPO is off**
- Monitor left at **60 Hz** although it supports 75/144/165 Hz
- Games installed on a **hard disk** instead of the SSD (load stutter, texture pop-in)
- Power plan, GPU scheduling, Game Mode, overlays and startup apps eating resources in the background

## What it does

1. **Scans read-only**: CPU, RAM modules and speeds, motherboard/BIOS age, GPU driver, monitor refresh rates, disks (SSD/HDD and free space), where your Steam / Epic / Riot / EA / Ubisoft / Battle.net games are installed, pagefile, power plan, Game Mode, HAGS, Memory Integrity, startup apps and running overlays.
2. **Explains**: a ranked list of findings (High / Medium / Low impact), what each one does and who has to fix it (Claude, you in Windows Settings, you in BIOS, or a purchase).
3. **Applies safe tweaks, only with your OK**: High performance power plan, disabling auto-start of launchers and sync apps (the same switch as Task Manager; nothing gets uninstalled), Game Mode, and hardware-accelerated GPU scheduling (admin only). **Everything is backed up first** and can be undone with one command.
4. **Guides you** through the steps it can't do itself, with exact menu paths: enabling XMP/EXPO for Gigabyte / MSI / ASUS / ASRock, refresh rate, NVIDIA / AMD / Intel panel settings, turning overlays off, moving games to the SSD.
5. **Verifies**: re-scans after changes and asks you to compare FPS in the same scene.

## What it will never do

- Disable Defender, Windows Update, the firewall or anti-cheat (Vanguard, EAC, BattlEye, FACEIT)
- Run "debloat" or "optimizer" scripts, mass-disable services, or apply undocumented registry/network tweaks
- Overclock, undervolt, flash your BIOS or uninstall your apps

## Install

Copy the folder into your Claude skills directory:

```powershell
git clone https://github.com/mustafacakar/windows-fps-booster-skill "$env:USERPROFILE\.claude\skills\windows-fps-booster"
```

Then just ask Claude something like:

> My games stutter and FPS drops in team fights, can you check my PC?

The skill also triggers on Turkish phrases ("oyun kasıyor", "FPS düşüyor") and answers in your language.

## Use the scripts without Claude

```powershell
# Read-only report
powershell -ExecutionPolicy Bypass -File scripts\diagnose.ps1

# Preview, then apply
powershell -ExecutionPolicy Bypass -File scripts\apply-tweaks.ps1 -HighPerformancePlan -DisableStartup "OneDrive","Teams" -EnableGameMode -WhatIf
powershell -ExecutionPolicy Bypass -File scripts\apply-tweaks.ps1 -HighPerformancePlan -DisableStartup "OneDrive","Teams" -EnableGameMode

# Undo (path is printed by apply-tweaks)
powershell -ExecutionPolicy Bypass -File scripts\restore.ps1 -BackupDir "$env:USERPROFILE\Desktop\fps-booster-backup\<timestamp>"
```

Run PowerShell as Administrator only if you also want `-EnableHAGS` or to disable machine-wide startup entries.

## Layout

```
SKILL.md                    workflow and rules Claude follows
references/findings.md      scan field -> verdict, impact, fix
references/manual-steps.md  BIOS / GPU panel / Windows menu paths
scripts/diagnose.ps1        read-only scan
scripts/apply-tweaks.ps1    reversible tweaks with backup
scripts/restore.ps1         undo
```

Requirements: Windows 10 or 11, Windows PowerShell 5.1+.

## Disclaimer

Gains depend on your hardware and games; the numbers in the skill are typical ranges, not promises. BIOS changes such as XMP are done by you, at your own risk. Read what a script does before running it.

## License

MIT
