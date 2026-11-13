# windows-fps-booster - applies only safe, reversible tweaks. Backs up first.
# Usage:
#   apply-tweaks.ps1 -HighPerformancePlan -DisableStartup "OneDrive","Teams" -EnableGameMode [-EnableHAGS] [-WhatIf]
[CmdletBinding()]
param(
  [switch]$HighPerformancePlan,
  [string[]]$DisableStartup = @(),
  [switch]$EnableGameMode,
  [switch]$EnableHAGS,
  [switch]$WhatIf
)

$ErrorActionPreference = 'Stop'
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not ($HighPerformancePlan -or $DisableStartup.Count -or $EnableGameMode -or $EnableHAGS)) {
  "Nothing selected. Use -HighPerformancePlan, -DisableStartup <names>, -EnableGameMode, -EnableHAGS."; exit 0
}

$runHKCU = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
$runHKLM = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run'
$apHKCU  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run'
$apHKLM  = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run'
$hpGuid  = '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'

if ($WhatIf) {
  "WHATIF - nothing will be changed:"
  if ($HighPerformancePlan) { "  Set power plan to High performance ($hpGuid)" }
  foreach ($n in $DisableStartup) { "  Disable auto-start of '$n' (app stays installed)" }
  if ($EnableGameMode) { "  Turn on Game Mode" }
  if ($EnableHAGS) { "  Turn on Hardware-accelerated GPU scheduling (admin: $isAdmin, reboot needed)" }
  exit 0
}

# ---- Backup ----
$bk = Join-Path ([Environment]::GetFolderPath('Desktop')) ("fps-booster-backup\" + (Get-Date -Format 'yyyyMMdd-HHmmss'))
New-Item -ItemType Directory -Force $bk | Out-Null
$active = (powercfg /getactivescheme) -replace '.*GUID:\s*([0-9a-fA-F-]{36}).*','$1'
Set-Content -Path (Join-Path $bk 'power-plan.txt') -Value $active.Trim() -Encoding ASCII
foreach ($k in @(
  @('HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run','startup-approved-hkcu.reg'),
  @('HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run','startup-approved-hklm.reg'),
  @('HKCU\Software\Microsoft\GameBar','gamebar.reg'),
  @('HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers','graphicsdrivers.reg'))) {
  & reg.exe export $k[0] (Join-Path $bk $k[1]) /y 2>$null | Out-Null
}
"Backup written to: $bk"

# ---- Power plan ----
if ($HighPerformancePlan) {
  $list = powercfg /list | Out-String
  if ($list -notmatch $hpGuid) { powercfg /duplicatescheme $hpGuid | Out-Null }
  powercfg /setactive $hpGuid
  "Power plan -> High performance"
}

# ---- Startup apps (same mechanism as Task Manager > Startup > Disable) ----
$disabledValue = [byte[]](3,0,0,0,0,0,0,0,0,0,0,0)
foreach ($name in $DisableStartup) {
  $done = $false
  foreach ($pair in @(@($runHKCU,$apHKCU,$false), @($runHKLM,$apHKLM,$true))) {
    $run = $null; try { $run = Get-ItemProperty $pair[0] -ErrorAction Stop } catch {}
    if ($run -and ($run.PSObject.Properties.Name -contains $name)) {
      if ($pair[2] -and -not $isAdmin) { "SKIPPED '$name' (machine-wide entry, needs admin - user can disable it in Task Manager > Startup)"; $done = $true; break }
      if (-not (Test-Path $pair[1])) { New-Item $pair[1] -Force | Out-Null }
      Set-ItemProperty -Path $pair[1] -Name $name -Value $disabledValue -Type Binary
      "Startup disabled: $name"; $done = $true; break
    }
  }
  if (-not $done) { "Not found in Run keys: $name (check Task Manager > Startup)" }
}

# ---- Game Mode ----
if ($EnableGameMode) {
  if (-not (Test-Path 'HKCU:\Software\Microsoft\GameBar')) { New-Item 'HKCU:\Software\Microsoft\GameBar' -Force | Out-Null }
  Set-ItemProperty 'HKCU:\Software\Microsoft\GameBar' -Name AutoGameModeEnabled -Value 1 -Type DWord
  Set-ItemProperty 'HKCU:\Software\Microsoft\GameBar' -Name AllowAutoGameMode -Value 1 -Type DWord
  "Game Mode -> on"
}

# ---- HAGS ----
if ($EnableHAGS) {
  if (-not $isAdmin) { "SKIPPED HAGS (needs admin). Manual: Settings > System > Display > Graphics > Change default graphics settings." }
  else {
    Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' -Name HwSchMode -Value 2 -Type DWord
    "HAGS -> on (reboot required)"
  }
}

"`nDone. To undo: restore.ps1 -BackupDir `"$bk`""
