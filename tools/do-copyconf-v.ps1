# COPY CONF 

$verbose = $true
$emuPath = "D:\Transfer-Lab"
$emuConf = "D:\Emulation\tools\EmuBiosTools\Emu - Tools\Conf"

function Copy-EmuConfig {
    param (
        [string]$sourceFile
    )

    if (-not (Test-Path $sourceFile)) {
        if ($verbose) { Write-Host "[INFO] Skipped: '$sourceFile' does not exist." -ForegroundColor Yellow }
        return
    }

    # Construit le chemin relatif depuis emuPath
    $relativePath = $sourceFile -replace [regex]::Escape("$emuPath\"), ""

    # Destination complète
    $targetFile = Join-Path $emuConf $relativePath
    $targetFolder = Split-Path $targetFile -Parent

    # Crée le dossier de destination si nécessaire
    if (-not (Test-Path $targetFolder)) {
        if ($verbose) { Write-Host "[INFO] Creating target folder: $targetFolder" }
        New-Item -ItemType Directory -Path $targetFolder -Force | Out-Null
    }

    # Si le fichier existe déjà, backup
    if (Test-Path $targetFile) {
        $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $backupFile = Join-Path "$emuConf\bkp\$relativePath" "$timestamp"
        $backupFolder = Split-Path $backupFile -Parent

        if (-not (Test-Path $backupFolder)) {
            New-Item -ItemType Directory -Path $backupFolder -Force | Out-Null
        }

        if ($verbose) {
            Write-Host "[INFO] Backup existing: $targetFile => $backupFile"
        }

        Move-Item -Path $targetFile -Destination $backupFile -Force
    }

    # Copie du fichier
    if ($verbose) {
        Write-Host "[INFO] Copying: $sourceFile => $targetFile"
    }

    Copy-Item -Path $sourceFile -Destination $targetFile -Force
}



	if ($verbose) { Write-Host "`n===== Setting up Emulator Storage =====" -ForegroundColor Magenta }

    Copy-EmuConfig "$emuPath\azahar\user\config\qt-config.ini"
    Copy-EmuConfig "$emuPath\Sega Model 3 UI -r886\Supermodel.ini"
    Copy-EmuConfig "$emuPath\Sega Model 3 UI -r886\Config\Supermodel.ini"

    if ($verbose) { Write-Host "Emulator Storage setup complete.`n" -ForegroundColor Green }



#EMULATORS

#Azahar - 3DS 

#BigPemu - Atari Jaguar

#Cemu - WiiU

#Citra - 3DS

#Citron - Switch	

#Dolphin - Gamecube - Wii

#Duckstation - PS1

#Flycast - Dreamcast

#lime3ds - 3DS

#m2emulator - Sega Model 2

#MAME

#MelonDS - DS

#mGBA - GBA

#PCSX2 - PS2

#Primehack - Wii Metroid

#PPSSPP - PSP

#Retroarch - Multi system 

#RPCS3 - PS3

#ryujinx - switch 

#Scummvm - Scummvm

#Shadps4 - PS4

#supermodel - SEGA Model 3 

#VITA3k - PSVita

#Xemu - Xbox

#Xenia - Xbox 360 

#yuzu - Switch 
