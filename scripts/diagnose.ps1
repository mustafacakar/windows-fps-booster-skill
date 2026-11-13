# windows-fps-booster - read-only system scan for gaming performance.
# Changes nothing. Windows PowerShell 5.1+ compatible.

$ErrorActionPreference = 'SilentlyContinue'

function Section($t) { "`n=== $t ===" }
function Try-Get($block) { try { & $block } catch { $null } }

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
Section 'Session'
"Elevated (admin): $isAdmin"

$os = Get-CimInstance Win32_OperatingSystem
Section 'OS'
"$($os.Caption) build $($os.BuildNumber)"
"RAM total GB: $([math]::Round($os.TotalVisibleMemorySize/1MB,1))  free GB: $([math]::Round($os.FreePhysicalMemory/1MB,1))"

Section 'CPU'
Get-CimInstance Win32_Processor | ForEach-Object { "$($_.Name.Trim())  cores=$($_.NumberOfCores) threads=$($_.NumberOfLogicalProcessors) baseMHz=$($_.MaxClockSpeed)" }

Section 'RAM modules'
$mods = @(Get-CimInstance Win32_PhysicalMemory)
"Module count: $($mods.Count)  (1 = single channel)"
foreach ($m in $mods) {
  "Slot=$($m.DeviceLocator) Bank=$($m.BankLabel) Part=$($m.PartNumber.Trim()) Maker=$($m.Manufacturer) GB=$([math]::Round($m.Capacity/1GB)) SpeedMHz=$($m.Speed) ConfiguredClockSpeedMHz=$($m.ConfiguredClockSpeed)"
}
"Hint: compare ConfiguredClockSpeed with the speed in the part number (e.g. KHX3000, 3200C16, F4-3600). Lower = XMP/EXPO off."

Section 'Motherboard / BIOS'
$bb = Get-CimInstance Win32_BaseBoard; $bios = Get-CimInstance Win32_BIOS
"Board: $($bb.Manufacturer) $($bb.Product)"
"BIOS: $($bios.SMBIOSBIOSVersion) date=$(if ($bios.ReleaseDate) { $bios.ReleaseDate.ToString('yyyy-MM-dd') })"

Section 'GPU'
Get-CimInstance Win32_VideoController | ForEach-Object {
  "$($_.Name)  driver=$($_.DriverVersion) driverDate=$(if ($_.DriverDate) { $_.DriverDate.ToString('yyyy-MM-dd') })  res=$($_.CurrentHorizontalResolution)x$($_.CurrentVerticalResolution)  refreshNow=$($_.CurrentRefreshRate)Hz refreshMax=$($_.MaxRefreshRate)Hz"
}

Section 'Monitors'
Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorID | ForEach-Object {
  (($_.UserFriendlyName | Where-Object { $_ -ne 0 } | ForEach-Object { [char]$_ }) -join '')
}
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Screen]::AllScreens | ForEach-Object { "$($_.DeviceName) primary=$($_.Primary) $($_.Bounds.Width)x$($_.Bounds.Height)" }
"Note: refreshMax above is reported by the driver for the primary adapter output; confirm per monitor in Settings > Display > Advanced display."

Section 'Disks'
$phys = @(Get-PhysicalDisk)
$phys | ForEach-Object { "Disk $($_.DeviceId): $($_.FriendlyName) Media=$($_.MediaType) Bus=$($_.BusType) GB=$([math]::Round($_.Size/1GB)) Health=$($_.HealthStatus)" }
$driveMedia = @{}
Get-Volume | Where-Object DriveLetter | ForEach-Object {
  $dl = $_.DriveLetter; $media = 'Unknown'
  $p = Try-Get { Get-Partition -DriveLetter $dl -ErrorAction Stop }
  if ($p) { $pd = $phys | Where-Object { $_.DeviceId -eq [string]$p.DiskNumber }; if ($pd) { $media = $pd.MediaType } }
  $driveMedia[[string]$dl] = $media
  $pct = if ($_.Size) { [math]::Round(100*$_.SizeRemaining/$_.Size) } else { 0 }
  "Volume ${dl}: Media=$media SizeGB=$([math]::Round($_.Size/1GB)) FreeGB=$([math]::Round($_.SizeRemaining/1GB)) Free%=$pct"
}

Section 'Game install locations'
$games = New-Object System.Collections.ArrayList
# Steam
$steamRoot = Try-Get { (Get-ItemProperty 'HKCU:\Software\Valve\Steam' -ErrorAction Stop).SteamPath }
if ($steamRoot) {
  $vdf = Join-Path $steamRoot 'steamapps\libraryfolders.vdf'
  $libs = @($steamRoot)
  if (Test-Path $vdf) { $libs += (Select-String -Path $vdf -Pattern '"path"\s+"([^"]+)"' -AllMatches).Matches | ForEach-Object { $_.Groups[1].Value -replace '\\\\','\' } }
  $seen = @{}
  $libs = foreach ($l in $libs) { $key = ($l -replace '/','\').TrimEnd('\').ToLower(); if (-not $seen.ContainsKey($key)) { $seen[$key] = 1; $l } }
  foreach ($l in $libs) {
    $common = Join-Path $l 'steamapps\common'
    if (Test-Path $common) { Get-ChildItem $common -Directory | ForEach-Object { [void]$games.Add(@('Steam', $_.Name, $_.FullName)) } }
  }
}
# Epic
$epicMan = 'C:\ProgramData\Epic\EpicGamesLauncher\Data\Manifests'
if (Test-Path $epicMan) {
  Get-ChildItem $epicMan -Filter *.item | ForEach-Object {
    $j = Try-Get { Get-Content $_.FullName -Raw | ConvertFrom-Json }
    if ($j -and $j.InstallLocation) { [void]$games.Add(@('Epic', $j.DisplayName, $j.InstallLocation)) }
  }
}
# Riot / EA / Ubisoft / Battle.net common roots on every drive
foreach ($dl in $driveMedia.Keys) {
  foreach ($sub in 'Riot Games','Program Files\EA Games','EA Games','Program Files (x86)\Ubisoft\Ubisoft Game Launcher\games','Program Files (x86)\Battle.net','Games') {
    $root = "${dl}:\$sub"
    if (Test-Path $root) { Get-ChildItem $root -Directory | ForEach-Object { [void]$games.Add(@($sub, $_.Name, $_.FullName)) } }
  }
}
if ($games.Count -eq 0) { "No games found in common locations - ask the user where their games are installed." }
foreach ($g in $games) {
  $dl = $g[2].Substring(0,1).ToUpper()
  "[$($g[0])] $($g[1]) -> $($g[2])  Media=$($driveMedia[$dl])"
}

Section 'Pagefile'
$pf = @(Get-CimInstance Win32_PageFileUsage)
if ($pf.Count -eq 0) { "No pagefile (disabled)" } else { $pf | ForEach-Object { "$($_.Name) allocatedMB=$($_.AllocatedBaseSize) peakMB=$($_.PeakUsage)" } }
$auto = (Get-CimInstance Win32_ComputerSystem).AutomaticManagedPagefile
"System managed: $auto"

Section 'Power plan'
powercfg /getactivescheme

Section 'Windows gaming settings'
$gb  = Try-Get { Get-ItemProperty 'HKCU:\Software\Microsoft\GameBar' -ErrorAction Stop }
$dvr = Try-Get { Get-ItemProperty 'HKCU:\System\GameConfigStore' -ErrorAction Stop }
$cap = Try-Get { Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR' -ErrorAction Stop }
$gd  = Try-Get { Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' -ErrorAction Stop }
"Game Mode (AutoGameModeEnabled): $(if ($gb -and $null -ne $gb.AutoGameModeEnabled) { $gb.AutoGameModeEnabled } else { 'default (on)' })"
"Xbox Game Bar (UseNexusForGameBarEnabled): $(if ($gb -and $null -ne $gb.UseNexusForGameBarEnabled) { $gb.UseNexusForGameBarEnabled } else { 'default' })"
"GameDVR_Enabled: $(if ($dvr) { $dvr.GameDVR_Enabled } else { 'unset' })   AppCaptureEnabled: $(if ($cap) { $cap.AppCaptureEnabled } else { 'unset' })"
"HAGS HwSchMode: $(if ($gd -and $null -ne $gd.HwSchMode) { $gd.HwSchMode } else { 'unset (off)' })  (2 = on, 1 = off)"

Section 'Memory Integrity / VBS'
$dg = Try-Get { Get-CimInstance -Namespace root\Microsoft\Windows\DeviceGuard -ClassName Win32_DeviceGuard -ErrorAction Stop }
if ($dg) { "VBS status: $($dg.VirtualizationBasedSecurityStatus) (0 off, 1 configured, 2 running)  Services running: $($dg.SecurityServicesRunning -join ',') (2 = Memory Integrity/HVCI)" } else { "Could not read" }

Section 'Startup apps (Run keys)'
$approvedHKCU = Try-Get { Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run' -ErrorAction Stop }
$approvedHKLM = Try-Get { Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run' -ErrorAction Stop }
foreach ($scope in @(@('HKCU','HKCU:\Software\Microsoft\Windows\CurrentVersion\Run',$approvedHKCU), @('HKLM','HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run',$approvedHKLM))) {
  $run = Try-Get { Get-ItemProperty $scope[1] -ErrorAction Stop }
  if (-not $run) { continue }
  $run.PSObject.Properties | Where-Object { $_.Name -notlike 'PS*' } | ForEach-Object {
    $state = 'enabled'
    if ($scope[2] -and $scope[2].PSObject.Properties.Name -contains $_.Name) { $b = $scope[2].($_.Name); if ($b -and ($b[0] % 2) -eq 1) { $state = 'disabled' } }
    "[$($scope[0])] $($_.Name)  ($state)"
  }
}
"Also check Task Manager > Startup and shell:startup folder for items not listed here."

Section 'Overlays / background apps running'
$pattern = 'NVIDIA Overlay|nvcontainer|RadeonSoftware|AMDRSServ|Discord|Overwolf|XboxGameBar|GameBar|MSIAfterburner|RTSS|iCUE|Armoury|LGHUB|lghub|Razer|Synapse|SignalRgb|wallpaper|OneDrive|Teams|Steam|EpicGamesLauncher|EADesktop|Origin|Battle.net|UbisoftConnect|Blitz|Medal|chrome|msedge|firefox'
Get-Process | Where-Object { $_.Name -match $pattern } | Group-Object Name | ForEach-Object {
  $mb = [math]::Round((($_.Group | Measure-Object WorkingSet64 -Sum).Sum)/1MB)
  "$($_.Name) x$($_.Count)  RAM_MB=$mb"
}

Section 'Top 10 processes by RAM'
Get-Process | Group-Object Name | ForEach-Object { [pscustomobject]@{ Name=$_.Name; MB=[math]::Round((($_.Group | Measure-Object WorkingSet64 -Sum).Sum)/1MB) } } | Sort-Object MB -Descending | Select-Object -First 10 | ForEach-Object { "$($_.Name)  RAM_MB=$($_.MB)" }

"`nScan complete. Nothing was changed."
