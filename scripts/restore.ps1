# windows-fps-booster - undo a run of apply-tweaks.ps1
# Usage: restore.ps1 -BackupDir "<Desktop>\fps-booster-backup\<timestamp>"
param([Parameter(Mandatory=$true)][string]$BackupDir)

if (-not (Test-Path $BackupDir)) { "Backup folder not found: $BackupDir"; exit 1 }
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

$planFile = Join-Path $BackupDir 'power-plan.txt'
if (Test-Path $planFile) { $g = (Get-Content $planFile -Raw).Trim(); powercfg /setactive $g; "Power plan restored: $g" }

# Values apply-tweaks may have created: remove them first so "was unset" is restored too
# (reg import only adds/overwrites, it never deletes).
Remove-ItemProperty 'HKCU:\Software\Microsoft\GameBar' -Name AutoGameModeEnabled,AllowAutoGameMode -ErrorAction SilentlyContinue
if ($isAdmin) { Remove-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' -Name HwSchMode -ErrorAction SilentlyContinue }

# Startup entries: clear current approvals, then re-import the backup.
foreach ($pair in @(
  @('startup-approved-hkcu.reg','HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run',$false),
  @('gamebar.reg','',$false),
  @('startup-approved-hklm.reg','HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run',$true),
  @('graphicsdrivers.reg','',$true))) {
  $f = Join-Path $BackupDir $pair[0]
  if (-not (Test-Path $f)) { continue }
  if ($pair[2] -and -not $isAdmin) { "SKIPPED $($pair[0]) (needs admin)"; continue }
  if ($pair[1]) { & reg.exe delete $pair[1] /f 2>$null | Out-Null }
  & reg.exe import $f 2>$null
  "Restored $($pair[0])"
}
"Done. Reboot if HAGS was changed."
