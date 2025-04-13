# COPY CONF 

    #the synlink userdata maybe needed   
    #mklink /d "D:\Emulation\Emulators\BigPEmu\config" "C:%APPDATA%\BigPEmu"

$verbose = $true
$emuPath = "D:\Emulation\Emulators"
$emuConf = "D:\Emulation\tools\EmuBiosTools\Emu - Tools\Conf"

function Copy-EmuConfig {
    param (
        [string]$sourceItem
    )

    # Si c’est un dossier avec wildcard
    if ($sourceItem -like '*`*') {
        $items = Get-ChildItem -Path $sourceItem -File -Recurse -ErrorAction SilentlyContinue
    }
    elseif (Test-Path $sourceItem -PathType Container) {
        $items = Get-ChildItem -Path $sourceItem -File -Recurse -ErrorAction SilentlyContinue
    }
    elseif (Test-Path $sourceItem -PathType Leaf) {
        $items = @((Get-Item -Path $sourceItem -ErrorAction SilentlyContinue))
    }
    else {
        if ($verbose) { Write-Host "[SKIP] Path not found: $sourceItem" -ForegroundColor Yellow }
        return
    }

    foreach ($item in $items) {
        $relativePath = $item.FullName -replace [regex]::Escape("$emuPath\"), ""
        $destinationPath = Join-Path $emuConf $relativePath
        $destinationDir = Split-Path $destinationPath -Parent

        # Crée le dossier cible si besoin
        if (-not (Test-Path $destinationDir)) {
            if ($verbose) { Write-Host "[INFO] Creating directory: $destinationDir" }
            New-Item -ItemType Directory -Path $destinationDir -Force | Out-Null
        }

        # Si un fichier existe déjà à destination, backup
        if (Test-Path $destinationPath) {
            $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
            $backupPath = Join-Path "$emuConf\bkp" $relativePath
            $backupPath = "$backupPath-$timestamp"
            $backupDir = Split-Path $backupPath -Parent

            if (-not (Test-Path $backupDir)) {
                New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
            }

            if ($verbose) { Write-Host "[BACKUP] $destinationPath => $backupPath" -ForegroundColor Cyan }
            Move-Item -Path $destinationPath -Destination $backupPath -Force
        }

        if ($verbose) { Write-Host "[COPY] $($item.FullName) => $destinationPath" -ForegroundColor Green }
        Copy-Item -Path $item.FullName -Destination $destinationPath -Force
    }
}

# EMULATORS
$pathsToCopy = @(
#Azahar - 3DS 
    "$emuPath\azahar\user\config\*"
#BigPemu - Atari Jaguar
    "$emuPath\BigPEmu\config\BigPEmuConfig.bigpcfg"
#Cemu - WiiU
    "$emuPath\cemu\settings.xml"
    "$emuPath\cemu\controllerProfiles\*"
#Citra - 3DS
    "$emuPath\citra\user\config\*"
#Citron - Switch	
    "$emuPath\Citron\user\config\*"
#Dolphin - Gamecube - Wii
    "$emuPath\Dolphin-x64\User\Config\*"
    "$emuPath\Dolphin-x64\Sys\Profiles\*"
#Duckstation - PS1
    "$emuPath\duckstation\settings.ini"
    "$emuPath\duckstation\portable.txt"
#EmulationStation-DE
    "$emuPath\EmulationStation-DE\ES-DE\custom_systems\*"
    "$emuPath\EmulationStation-DE\ES-DE\settings\*"
#Flycast - Dreamcast
    "$emuPath\flycast\emu.cfg"
    "$emuPath\flycast\D3DX9_43.dll"
#lime3ds - 3DS
    "$emuPath\lime3ds\user\config\*"
#m2emulator - Sega Model 2
    "$emuPath\m2emulator\CFG\*"
    "$emuPath\m2emulator\NVDATA\*"
    "$emuPath\m2emulator\scripts\*"
    "$emuPath\m2emulator\EMULATOR.INI"
#MAME
    "$emuPath\mame\mame.ini"
    "$emuPath\mame\cfg\*"
#MelonDS - DS
    "$emuPath\melonDS\melonDS.ini"
#mGBA - GBA
    "$emuPath\mGBA\config.ini"
    "$emuPath\mGBA\qt.ini"
#PCSX2 - PS2
    "$emuPath\PCSX2-Qt\inis\*"
    "$emuPath\PCSX2-Qt\portable.ini"
#Primehack - Wii Metroid
    "$emuPath\PrimeHack\User\Config\*"
    "$emuPath\PrimeHack\portable.txt"
    "$emuPath\PrimeHack\User\GameSettings\*"
    "$emuPath\PrimeHack\User\Load\Textures\R3M\*"
#PPSSPP - PSP
    "$emuPath\PPSSPP\memstick\PSP\SYSTEM\controls.ini"
    "$emuPath\PPSSPP\memstick\PSP\SYSTEM\ppsspp.ini"	
#Retroarch - Multi system 
    "$emuPath\RetroArch-Win64\autoconfig\*"
    "$emuPath\RetroArch-Win64\config\*"
    "$emuPath\RetroArch-Win64\retroarch.cfg"
#RPCS3 - PS3
    "$emuPath\RPCS3\config\*"
#ryujinx - switch 
    "$emuPath\ryujinx\portable\Config.json"
#Scummvm - Scummvm
    "$emuPath\scummvm\scummvm.ini"
#Shadps4 - PS4
    "$emuPath\shadPS4\user\config.toml"
#supermodel - SEGA Model 3 
    "$emuPath\Supermodel\Config\*"
#VITA3k - PSVita
    "$emuPath\Vita3K\config.yml"
#Xemu - Xbox
    "$emuPath\xemu\xemu.toml"
    "$emuPath\xemu\eeprom.bin"	
#Xenia - Xbox 360 
    "$emuPath\xenia_canary\xenia.config.toml"
    "$emuPath\xenia_canary\xenia-canary.config.toml"
    "$emuPath\xenia_canary\portable.txt"	
#yuzu - Switch 
    "$emuPath\yuzu\user\config\*"
)

foreach ($p in $pathsToCopy) {
	if ($verbose) { Write-Host "`n===== Setting up  $p =====" -ForegroundColor Magenta }
    Copy-EmuConfig $p
	 if ($verbose) { Write-Host " $p setup complete.`n" -ForegroundColor Green }
}
