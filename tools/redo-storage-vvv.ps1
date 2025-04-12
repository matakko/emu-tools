# Enter your path here. 
# $emusPath is for your /Emulators folder that can be in %APPDATA%/EmuDeck/Emulators or directly in EmulationStation-DE/Emulators
# $emulationPath is for your /Emulation folder where you will have the /saves folder
# - This script will check /Emulators folder if emulator Name dosnt exist = do nothing 
# - if emulator Name exist = check saves path exist ? if no create folder. for ex: Azahar exist yes, but user/sdmc or user/states doesnt exist = create the path /user/sdmc and user/states in Azahar emulator.
# - Then in /emulation/saves folder it check if destitnation folder exist if yes : Check symlink exist yes = do nothing 
# - Check symlink exist no ? but conflict names ?! To avoid interaction = create bkp folder in /emulation/saves and move the non linked / conflincting save in  /emulation/saves/bkp respecting the logic . for ex: /emulation/saves/bkp/azahar/states-"yyyyMMdd-HHmmss"
# - Check symlink exist no ? no conflict ? Do the symlink . 
# BEFORE USING  - MAIN ISSUE : PATH NAMES CAN DIFFER from mine -  LOGIC can diifer with STORAGE HDD NAND emulators as i keep everything related to storage  / nand / hdd in the emulators folders. 
# SO SYMLINK will show in /emulations/saves and not inside the emnulators folders.
# ANOTHER LIMITATION > i find a bug with Xenia  . i think windows only check the 5 first caracter for the first condition : "will check /Emulators folder if emulator Name dosnt exist = do nothing " 
# For example mine is xenia_canary , and i tried the scrpt with the folder name "xenia" the script still think xenia folder exist despite not existing the name is xenia_canary . So the first condition seems to validate the first 5 caracter without really having it right . 
# THIS can cause false positive creation of empty folder . 
# ANOTHER limitation is some emulators need to have the config or the ini to tell them the path saves for ex : MelonDS / mGBA / Supermodel ? might need verification 

$verbose = $true
$emusPath = "D:\Emulation\Emulators"
$storagePath = "D:\Emulation\storage"

function createSaveLink($target, $linkPath) {
    if ($verbose) { Write-Host "`n[INFO] Preparing symbolic link..." }

    $targetRoot = (Split-Path -Path (Split-Path -Path $target -Parent) -Parent)

    if (-Not (Test-Path $targetRoot)) {
        if ($verbose) { Write-Host "[WARN] Emulator root folder '$targetRoot' does not exist. Skipping link creation." }
        return
    }

    $targetParent = Split-Path -Path $target -Parent
    if (-Not (Test-Path $targetParent)) {
        if ($verbose) { Write-Host "[INFO] Creating target parent folder: '$targetParent'" }
        New-Item -ItemType Directory -Path $targetParent -Force  #| Out-Null
    }

    if (-Not (Test-Path $target)) {
        if ($verbose) { Write-Host "[INFO] Creating missing target directory: '$target'" }
        New-Item -ItemType Directory -Path $target -Force  #| Out-Null
    }

    $linkParent = Split-Path -Path $linkPath -Parent
    if (-Not (Test-Path $linkParent)) {
        if ($verbose) { Write-Host "[INFO] Creating parent directory for link: '$linkParent'" }
        New-Item -ItemType Directory -Path $linkParent -Force  #| Out-Null
    }
	
    # If a symbolic link already exists, do nothing
    if (Test-Path $linkPath) {
        $linkItem = Get-Item $linkPath -Force
        if ($linkItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
            if ($verbose) { Write-Host "[INFO] Symbolic link already exists. Skipping: '$linkPath'" }
            return
        }

    # Otherwise, move the save folder to backup
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $savesBase = $storagePath
    $relativePath = $linkPath -replace [regex]::Escape("$savesBase\"), ""
    $emulatorFolder = $relativePath.Split("\")[0]
    $subPath = $relativePath -replace [regex]::Escape("$emulatorFolder\"), ""
    $backupName = "$subPath-$timestamp"
    $backupPath = Join-Path "$savesBase\bkp\$emulatorFolder" $backupName
    
    $backupParent = Split-Path $backupPath -Parent
    if (-Not (Test-Path $backupParent)) {
        New-Item -ItemType Directory -Path $backupParent -Force #| Out-Null
    }
    
    if ($verbose) { Write-Host "[INFO] Moving conflicting folder to backup: '$backupPath'" }
    Move-Item -Path $linkPath -Destination $backupPath -Force
    }

    # Create the new symbolic link 
    if ($verbose) { Write-Host "[INFO] Creating symbolic link: '$linkPath' => '$target'" }
    New-Item -ItemType SymbolicLink -Path $linkPath -Target $target #| Out-Null
}



#Azahar - 3DS 
function Azahar_setupStorage() {
	if ($verbose) { Write-Host "`n===== Setting up Azahar Storage =====" -ForegroundColor Magenta }

	$simLinkPath = "$emusPath\azahar\user\cheats"
	$emuSavePath = "$storagePath\azahar\cheats"
	createSaveLink $simLinkPath $emuSavePath
	
	$simLinkPath = "$emusPath\azahar\user\nand"
	$emuSavePath = "$storagePath\azahar\nand"
	createSaveLink $simLinkPath $emuSavePath

	$simLinkPath = "$emusPath\azahar\user\screenshots"
	$emuSavePath = "$storagePath\azahar\screenshots"
	createSaveLink $simLinkPath $emuSavePath

	$simLinkPath = "$emusPath\azahar\user\sdmc"
	$emuSavePath = "$storagePath\azahar\sdmc"
	createSaveLink $simLinkPath $emuSavePath

	$simLinkPath = "$emusPath\azahar\user\load\textures"
	$emuSavePath = "$storagePath\azahar\textures"
	createSaveLink $simLinkPath $emuSavePath	

    if ($verbose) { Write-Host "Azahar Storage setup complete.`n" -ForegroundColor Green }	
}
#Cemu - WiiU

#Citra - 3DS
function Citra_setupStorage() {
	if ($verbose) { Write-Host "`n===== Setting up Citra Storage =====" -ForegroundColor Magenta }

	$simLinkPath = "$emusPath\citra\user\cheats"
	$emuSavePath = "$storagePath\citra\cheats"
	createSaveLink $simLinkPath $emuSavePath
	
	$simLinkPath = "$emusPath\citra\user\nand"
	$emuSavePath = "$storagePath\citra\nand"
	createSaveLink $simLinkPath $emuSavePath

	$simLinkPath = "$emusPath\citra\user\screenshots"
	$emuSavePath = "$storagePath\citra\screenshots"
	createSaveLink $simLinkPath $emuSavePath

	$simLinkPath = "$emusPath\citra\user\sdmc"
	$emuSavePath = "$storagePath\citra\sdmc"
	createSaveLink $simLinkPath $emuSavePath

	$simLinkPath = "$emusPath\citra\user\load\textures"
	$emuSavePath = "$storagePath\citra\textures"
	createSaveLink $simLinkPath $emuSavePath	

    if ($verbose) { Write-Host "Citra Storage setup complete.`n" -ForegroundColor Green }	
}

#Citron - Switch	
function Citron_setupStorage() {
	if ($verbose) { Write-Host "`n===== Setting up Citron Storage =====" -ForegroundColor Magenta }

	$simLinkPath = "$emusPath\citron\user\nand\user\Contents\registered"
	$emuSavePath = "$storagePath\citron\DLC"
	createSaveLink $simLinkPath $emuSavePath

	$simLinkPath = "$emusPath\citron\user\nand\system\Contents\registered"
	$emuSavePath = "$storagePath\citron\firmware"
	createSaveLink $simLinkPath $emuSavePath	
	
	$simLinkPath = "$emusPath\citron\user\screenshots"
	$emuSavePath = "$storagePath\citron\screenshots"
	createSaveLink $simLinkPath $emuSavePath
	
	$simLinkPath = "$emusPath\citron\user\dump"
	$emuSavePath = "$storagePath\citron\dump"
	createSaveLink $simLinkPath $emuSavePath
		
	$simLinkPath = "$emusPath\citron\user\mod"
	$emuSavePath = "$storagePath\citron\load"
	createSaveLink $simLinkPath $emuSavePath
		
	$simLinkPath = "$emusPath\citron\user\keys"
	$emuSavePath = "$storagePath\citron\keys"
	createSaveLink $simLinkPath $emuSavePath
		
	$simLinkPath = "$emusPath\citron\user\sdmc"
	$emuSavePath = "$storagePath\citron\sdmc"
	createSaveLink $simLinkPath $emuSavePath
			
	$simLinkPath = "$emusPath\citron\user\tas"
	$emuSavePath = "$storagePath\citron\tas"
	createSaveLink $simLinkPath $emuSavePath
	
    if ($verbose) { Write-Host "Citron Storage setup complete.`n" -ForegroundColor Green }	
}

#Dolphin - Gamecube Wii
function Dolphin_setupStorage() {
	if ($verbose) { Write-Host "`n===== Setting up Dolphin Storage =====" -ForegroundColor Magenta }

	$simLinkPath = "$emusPath\Dolphin-x64\User\Load\Textures"
	$emuSavePath = "$storagePath\Dolphin\Textures"
	createSaveLink $simLinkPath $emuSavePath
	
	$simLinkPath = "$emusPath\Dolphin-x64\User\ScreenShots"
	$emuSavePath = "$storagePath\Dolphin\ScreenShots"
	createSaveLink $simLinkPath $emuSavePath

	$simLinkPath = "$emusPath\Dolphin-x64\User\Wii\shared2\menu\FaceLib"
	$emuSavePath = "$storagePath\Dolphin\Mii_profile"
	createSaveLink $simLinkPath $emuSavePath
	
    if ($verbose) { Write-Host "Dolphin Storage setup complete.`n" -ForegroundColor Green }	
}

#Duckstation - PS1
function Duckstation_setupStorage() {
	if ($verbose) { Write-Host "`n===== Setting up Duckstation Storage =====" -ForegroundColor Magenta }

	$simLinkPath = "$emusPath\duckstation\cheats"
	$emuSavePath = "$storagePath\duckstation\cheats"
	createSaveLink $simLinkPath $emuSavePath
	
	$simLinkPath = "$emusPath\duckstation\textures"
	$emuSavePath = "$storagePath\duckstation\textures"
	createSaveLink $simLinkPath $emuSavePath
	
	$simLinkPath = "$emusPath\duckstation\patches"
	$emuSavePath = "$storagePath\duckstation\patches"
	createSaveLink $simLinkPath $emuSavePath
	
	$simLinkPath = "$emusPath\duckstation\screenshots"
	$emuSavePath = "$storagePath\duckstation\screenshots"
	createSaveLink $simLinkPath $emuSavePath
	
    if ($verbose) { Write-Host "Duckstation Storage setup complete.`n" -ForegroundColor Green }	
}

#Flycast - Dreamcast
function Flycast_setupStorage() {
	if ($verbose) { Write-Host "`n===== Setting up Flycast Storage =====" -ForegroundColor Magenta }

	$simLinkPath = "$emusPath\flycast\data\textures"
	$emuSavePath = "$storagePath\flycast\textures"
	createSaveLink $simLinkPath $emuSavePath
	
	$simLinkPath = "$emusPath\flycast\data\texdump"
	$emuSavePath = "$storagePath\flycast\dump"
	createSaveLink $simLinkPath $emuSavePath
	
    if ($verbose) { Write-Host "Flycast Storage setup complete.`n" -ForegroundColor Green }	
}

#Lime3ds - 3DS
function Lime3ds_setupStorage() {
	if ($verbose) { Write-Host "`n===== Setting up Lime3ds Storage =====" -ForegroundColor Magenta }

	$simLinkPath = "$emusPath\lime3ds\user\cheats"
	$emuSavePath = "$storagePath\lime3ds\cheats"
	createSaveLink $simLinkPath $emuSavePath
	
	$simLinkPath = "$emusPath\lime3ds\user\nand"
	$emuSavePath = "$storagePath\lime3ds\nand"
	createSaveLink $simLinkPath $emuSavePath

	$simLinkPath = "$emusPath\lime3ds\user\screenshots"
	$emuSavePath = "$storagePath\lime3ds\screenshots"
	createSaveLink $simLinkPath $emuSavePath

	$simLinkPath = "$emusPath\lime3ds\user\sdmc"
	$emuSavePath = "$storagePath\lime3ds\sdmc"
	createSaveLink $simLinkPath $emuSavePath

	$simLinkPath = "$emusPath\lime3ds\user\load\textures"
	$emuSavePath = "$storagePath\lime3ds\textures"
	createSaveLink $simLinkPath $emuSavePath	

    if ($verbose) { Write-Host "Lime3ds Storage setup complete.`n" -ForegroundColor Green }	
}

#m2emulator - Sega Model 2

#MAME 
function MAME_setupStorage() {
	if ($verbose) { Write-Host "`n===== Setting up MAME Storage =====" -ForegroundColor Magenta }

	$simLinkPath = "$emusPath\mame\samples"
	$emuSavePath = "$storagePath\mame\samples"
	createSaveLink $simLinkPath $emuSavePath
	
	$simLinkPath = "$emusPath\mame\artwork"
	$emuSavePath = "$storagePath\mame\artwork"
	createSaveLink $simLinkPath $emuSavePath
	
	$simLinkPath = "$emusPath\mame\ctrlr"
	$emuSavePath = "$storagePath\mame\ctrlr"
	createSaveLink $simLinkPath $emuSavePath
	
	$simLinkPath = "$emusPath\mame\ini"
	$emuSavePath = "$storagePath\mame\ini"
	createSaveLink $simLinkPath $emuSavePath
	
	$simLinkPath = "$emusPath\mame\cheat"
	$emuSavePath = "$storagePath\mame\cheat"
	createSaveLink $simLinkPath $emuSavePath
				
    if ($verbose) { Write-Host "MAME Storage setup complete.`n" -ForegroundColor Green }	
}

#MelonDS - DS
function MelonDS_setupStorage() {
	if ($verbose) { Write-Host "`n===== Setting up MelonDS Storage =====" -ForegroundColor Magenta }

	$simLinkPath = "$emusPath\melonDS\cheats"
	$emuSavePath = "$storagePath\melonDS\cheats"
	createSaveLink $simLinkPath $emuSavePath
				
    if ($verbose) { Write-Host "MelonDS Storage setup complete.`n" -ForegroundColor Green }	
}

#mGBA - GBA
function mGBA_setupStorage() {
	if ($verbose) { Write-Host "`n===== Setting up mGBA Storage =====" -ForegroundColor Magenta }

	$simLinkPath = "$emusPath\mGBA\patches"
	$emuSavePath = "$storagePath\mGBA\patches"
	createSaveLink $simLinkPath $emuSavePath

	$simLinkPath = "$emusPath\mGBA\screenshots"
	$emuSavePath = "$storagePath\mGBA\screenshots"
	createSaveLink $simLinkPath $emuSavePath
	
	$simLinkPath = "$emusPath\mGBA\cheats"
	$emuSavePath = "$storagePath\mGBA\cheats"
	createSaveLink $simLinkPath $emuSavePath
	
    if ($verbose) { Write-Host "mGBA Storage setup complete.`n" -ForegroundColor Green }	
}

#PCSX2 - PS2
function PCSX2_setupStorage() {
	if ($verbose) { Write-Host "`n===== Setting up PCSX2 Storage =====" -ForegroundColor Magenta }

	$simLinkPath = "$emusPath\PCSX2-Qt\cheats"
	$emuSavePath = "$storagePath\PCSX2-Qt\cheats"
	createSaveLink $simLinkPath $emuSavePath
	
	$simLinkPath = "$emusPath\PCSX2-Qt\textures"
	$emuSavePath = "$storagePath\PCSX2-Qt\textures"
	createSaveLink $simLinkPath $emuSavePath
	
	$simLinkPath = "$emusPath\PCSX2-Qt\patches"
	$emuSavePath = "$storagePath\PCSX2-Qt\patches"
	createSaveLink $simLinkPath $emuSavePath
	
    if ($verbose) { Write-Host "PCSX2 Storage setup complete.`n" -ForegroundColor Green }	
}

#Primehack - Wii Metroid
function Primehack_setupStorage() {
	if ($verbose) { Write-Host "`n===== Setting up Primehack Storage =====" -ForegroundColor Magenta }

	$simLinkPath = "$emusPath\PrimeHack\User\Load\Textures"
	$emuSavePath = "$storagePath\PrimeHack\Textures"
	createSaveLink $simLinkPath $emuSavePath
	
	$simLinkPath = "$emusPath\PrimeHack\User\ScreenShots"
	$emuSavePath = "$storagePath\PrimeHack\ScreenShots"
	createSaveLink $simLinkPath $emuSavePath
	
    if ($verbose) { Write-Host "Primehack Storage setup complete.`n" -ForegroundColor Green }	
}

#PPSSPP - PSP
function PPSSPP_setupStorage() {
	if ($verbose) { Write-Host "`n===== Setting up PPSSPP Storage =====" -ForegroundColor Magenta }

	$simLinkPath = "$emusPath\PPSSPP\memstick\PSP\Cheats"
	$emuSavePath = "$storagePath\PPSSPP\Cheats"
	createSaveLink $simLinkPath $emuSavePath
	
	$simLinkPath = "$emusPath\PPSSPP\memstick\PSP\GAME"
	$emuSavePath = "$storagePath\PPSSPP\DLC_GAME"
	createSaveLink $simLinkPath $emuSavePath
	
	$simLinkPath = "$emusPath\PPSSPP\memstick\PSP\SAVEDATA"
	$emuSavePath = "$storagePath\PPSSPP\DLC_SAVEDATA"
	createSaveLink $simLinkPath $emuSavePath
	
	$simLinkPath = "$emusPath\PPSSPP\memstick\PSP\TEXTURES"
	$emuSavePath = "$storagePath\PPSSPP\TEXTURES"
	createSaveLink $simLinkPath $emuSavePath
	
    if ($verbose) { Write-Host "PPSSPP Storage setup complete.`n" -ForegroundColor Green }	
}

#Retroarch - Multi system 
function Retroarch_setupStorage() {
	if ($verbose) { Write-Host "`n===== Setting up Retroarch Storage =====" -ForegroundColor Magenta }

	$simLinkPath = "$emusPath\RetroArch-Win64\cores"
	$emuSavePath = "$storagePath\RetroArch\cores"
	createSaveLink $simLinkPath $emuSavePath
	
	$simLinkPath = "$emusPath\RetroArch-Win64\cheats"
	$emuSavePath = "$storagePath\RetroArch\cheats"
	createSaveLink $simLinkPath $emuSavePath
	
	$simLinkPath = "$emusPath\RetroArch-Win64\screenshots"
	$emuSavePath = "$storagePath\RetroArch\screenshots"
	createSaveLink $simLinkPath $emuSavePath
	
    if ($verbose) { Write-Host "Retroarch Storage setup complete.`n" -ForegroundColor Green }	
}

#RPCS3 - PS3
function RPCS3_setupStorage() {
	if ($verbose) { Write-Host "`n===== Setting up RPCS3 Storage =====" -ForegroundColor Magenta }

	$simLinkPath = "$emusPath\RPCS3\dev_hdd0"
	$emuSavePath = "$storagePath\RPCS3\dev_hdd0"
	createSaveLink $simLinkPath $emuSavePath
	
    if ($verbose) { Write-Host "RPCS3 Storage setup complete.`n" -ForegroundColor Green }	
}

#Ryujinx - switch 
function Ryujinx_setupStorage() {
	if ($verbose) { Write-Host "`n===== Setting up Ryujinx Storage =====" -ForegroundColor Magenta }

	$simLinkPath = "$emusPath\ryujinx\portable\mods"
	$emuSavePath = "$storagePath\ryujinx\mods"
	createSaveLink $simLinkPath $emuSavePath

	$simLinkPath = "$emusPath\ryujinx\portable\games"
	$emuSavePath = "$storagePath\ryujinx\games"
	createSaveLink $simLinkPath $emuSavePath
	
	$simLinkPath = "$emusPath\ryujinx\portable\screenshots"
	$emuSavePath = "$storagePath\ryujinx\screenshots"
	createSaveLink $simLinkPath $emuSavePath
	
	$simLinkPath = "$emusPath\ryujinx\portable\patchesAndDLC"
	$emuSavePath = "$storagePath\ryujinx\patchesAndDLC"
	createSaveLink $simLinkPath $emuSavePath
		
	$simLinkPath = "$emusPath\ryujinx\portable\system"
	$emuSavePath = "$storagePath\ryujinx\keys"
	createSaveLink $simLinkPath $emuSavePath
	
    if ($verbose) { Write-Host "Ryujinx Storage setup complete.`n" -ForegroundColor Green }	
}

#Scummvm - Scummvm

#Shadps4 - PS4
function Shadps4_setupStorage() {
	if ($verbose) { Write-Host "`n===== Setting up Shadps4 Storage =====" -ForegroundColor Magenta }

	$simLinkPath = "$emusPath\shadPS4\storage\games"
	$emuSavePath = "$storagePath\shadPS4\games"
	createSaveLink $simLinkPath $emuSavePath
	
	$simLinkPath = "$emusPath\shadPS4\storage\dlc"
	$emuSavePath = "$storagePath\shadPS4\dlc"
	createSaveLink $simLinkPath $emuSavePath
	
	$simLinkPath = "$emusPath\shadPS4\user\sys_modules"
	$emuSavePath = "$storagePath\shadPS4\sys_modules"
	createSaveLink $simLinkPath $emuSavePath
	
	$simLinkPath = "$emusPath\shadPS4\user\patches"
	$emuSavePath = "$storagePath\shadPS4\patches"
	createSaveLink $simLinkPath $emuSavePath
				
    if ($verbose) { Write-Host "Shadps4 Storage setup complete.`n" -ForegroundColor Green }	
}

#supermodel - SEGA Model 3 

#VITA3k - PSVita
function VITA3k_setupStorage() {
	if ($verbose) { Write-Host "`n===== Setting up VITA3k Storage =====" -ForegroundColor Magenta }

	$simLinkPath = "$emusPath\Vita3K\storage"
	$emuSavePath = "$storagePath\Vita3K\storage"
	createSaveLink $simLinkPath $emuSavePath
	

	$simLinkPath = "$emusPath\Vita3K\storage\ux0\app"
	$emuSavePath = "D:\Emulation\roms\psvita\InstalledGames"
	createSaveLink $simLinkPath $emuSavePath
	
				
    if ($verbose) { Write-Host "VITA3k Storage setup complete.`n" -ForegroundColor Green }	
}

#Xemu - Xbox
function Xemu_setupStorage() {
	if ($verbose) { Write-Host "`n===== Setting up Xemu Storage =====" -ForegroundColor Magenta }

	$simLinkPath = "$emusPath\xemu\storage"
	$emuSavePath = "$storagePath\xemu\storage"
	createSaveLink $simLinkPath $emuSavePath
				
    if ($verbose) { Write-Host "Xemu Storage setup complete.`n" -ForegroundColor Green }	
}

#Xenia - Xbox 360 
function Xenia_setupStorage() {
	if ($verbose) { Write-Host "`n===== Setting up Xenia Storage =====" -ForegroundColor Magenta }

	$simLinkPath = "$emusPath\xenia_canary\patches"
	$emuSavePath = "$storagePath\xenia_canary\patches"
	createSaveLink $simLinkPath $emuSavePath
	
    if ($verbose) { Write-Host "Xenia Storage setup complete.`n" -ForegroundColor Green }	
}

#Yuzu - Switch 
function Yuzu_setupStorage() {
	if ($verbose) { Write-Host "`n===== Setting up Yuzu Storage =====" -ForegroundColor Magenta }

	$simLinkPath = "$emusPath\yuzu\user\nand\user\Contents\registered"
	$emuSavePath = "$storagePath\yuzu\DLC"
	createSaveLink $simLinkPath $emuSavePath

	$simLinkPath = "$emusPath\yuzu\user\nand\system\Contents\registered"
	$emuSavePath = "$storagePath\yuzu\firmware"
	createSaveLink $simLinkPath $emuSavePath
	
	$simLinkPath = "$emusPath\yuzu\user\screenshots"
	$emuSavePath = "$storagePath\yuzu\screenshots"
	createSaveLink $simLinkPath $emuSavePath
	
	$simLinkPath = "$emusPath\yuzu\user\dump"
	$emuSavePath = "$storagePath\yuzu\dump"
	createSaveLink $simLinkPath $emuSavePath
		
	$simLinkPath = "$emusPath\yuzu\user\load"
	$emuSavePath = "$storagePath\yuzu\load"
	createSaveLink $simLinkPath $emuSavePath
		
	$simLinkPath = "$emusPath\yuzu\user\keys"
	$emuSavePath = "$storagePath\yuzu\keys"
	createSaveLink $simLinkPath $emuSavePath
		
	$simLinkPath = "$emusPath\yuzu\user\sdmc"
	$emuSavePath = "$storagePath\yuzu\sdmc"
	createSaveLink $simLinkPath $emuSavePath
			
	$simLinkPath = "$emusPath\yuzu\user\tas"
	$emuSavePath = "$storagePath\yuzu\tas"
	createSaveLink $simLinkPath $emuSavePath
	
    if ($verbose) { Write-Host "Yuzu Storage setup complete.`n" -ForegroundColor Green }	
}




Azahar_setupStorage

Citra_setupStorage

Citron_setupStorage

Duckstation_setupStorage

Dolphin_setupStorage

Flycast_setupStorage

Lime3ds_setupStorage

MAME_setupStorage

MelonDS_setupStorage

mGBA_setupStorage

PCSX2_setupStorage

PPSSPP_setupStorage

Primehack_setupStorage

Retroarch_setupStorage

RPCS3_setupStorage

Ryujinx_setupStorage

Shadps4_setupStorage

VITA3k_setupStorage

Yuzu_setupStorage

Xemu_setupStorage

Xenia_setupStorage
