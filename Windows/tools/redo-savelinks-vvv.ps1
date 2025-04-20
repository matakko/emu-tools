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
$emulationPath = "D:\Emulation"

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
        New-Item -ItemType Directory -Path $targetParent -Force  | Out-Null
    }

    if (-Not (Test-Path $target)) {
        if ($verbose) { Write-Host "[INFO] Creating missing target directory: '$target'" }
        New-Item -ItemType Directory -Path $target -Force  | Out-Null
    }

    $linkParent = Split-Path -Path $linkPath -Parent
    if (-Not (Test-Path $linkParent)) {
        if ($verbose) { Write-Host "[INFO] Creating parent directory for link: '$linkParent'" }
        New-Item -ItemType Directory -Path $linkParent -Force  | Out-Null
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
        $savesBase = Join-Path $emulationPath "saves"
        $relativePath = $linkPath -replace [regex]::Escape("$savesBase\"), ""
        $emulatorFolder = $relativePath.Split("\")[0]
        $subPath = $relativePath -replace [regex]::Escape("$emulatorFolder\"), ""
        $backupName = "$subPath-$timestamp"
        $backupPath = Join-Path "$savesBase\bkp\$emulatorFolder" $backupName

        $backupParent = Split-Path $backupPath -Parent
        if (-Not (Test-Path $backupParent)) {
            New-Item -ItemType Directory -Path $backupParent -Force | Out-Null
        }

        if ($verbose) { Write-Host "[INFO] Moving conflicting folder to backup: '$backupPath'" }
        Move-Item -Path $linkPath -Destination $backupPath -Force
    }

    # Create the new symbolic link
    if ($verbose) { Write-Host "[INFO] Creating symbolic link: '$linkPath' => '$target'" }
    New-Item -ItemType SymbolicLink -Path $linkPath -Target $target | Out-Null
}

#Azahar - 3DS
function Azahar_setupSaves() {
    if ($verbose) { Write-Host "`n===== Setting up azahar saves =====" -ForegroundColor Magenta }

	$simLinkPath = "$emusPath\azahar\user\sdmc"
	$emuSavePath = "$emulationPath\saves\azahar\saves"
	createSaveLink $simLinkPath $emuSavePath

	$simLinkPath = "$emusPath\azahar\user\states"
	$emuSavePath = "$emulationPath\saves\azahar\states"
	createSaveLink $simLinkPath $emuSavePath

    if ($verbose) { Write-Host "azahar save setup complete.`n" -ForegroundColor Green }
}
#BigPEMU - Atari
function BigPEmu_setupSaves(){
    if ($verbose) { Write-Host "`n===== Setting up BigPEmu saves =====" -ForegroundColor Magenta }

	$simLinkPath = "$emusPath\BigPEmu\saves"
	$emuSavePath = "$emulationPath\saves\BigPEmu\saves"
	createSaveLink $simLinkPath $emuSavePath

    if ($verbose) { Write-Host "BigPEmu save setup complete.`n" -ForegroundColor Green }
}

#Cemu - WiiU
function Cemu_setupSaves(){
    if ($verbose) { Write-Host "`n===== Setting up cemu saves =====" -ForegroundColor Magenta }

	$simLinkPath = "$emusPath\cemu\mlc01\usr\save"
	$emuSavePath = "$emulationPath\saves\Cemu\saves"
	createSaveLink $simLinkPath $emuSavePath

    if ($verbose) { Write-Host "cemu save setup complete.`n" -ForegroundColor Green }
}

# Citra - 3DS
function Citra_setupSaves(){
	if ($verbose) { Write-Host "`n===== Setting up citra saves =====" -ForegroundColor Magenta }

	$simLinkPath = "$emusPath\citra\user\sdmc"
	$emuSavePath = "$emulationPath\saves\citra\saves"
	createSaveLink $simLinkPath $emuSavePath

	$simLinkPath = "$emusPath\citra\user\states"
	$emuSavePath = "$emulationPath\saves\citra\states"
	createSaveLink $simLinkPath $emuSavePath

    if ($verbose) { Write-Host "citra save setup complete.`n" -ForegroundColor Green }
}

#Citron - Switch
function Citron_setupSaves(){
	if ($verbose) { Write-Host "`n===== Setting up citron saves =====" -ForegroundColor Magenta }

	$simLinkPath = "$emusPath\citron\user\nand\user\save"
	$emuSavePath = "$emulationPath\saves\citron\saves"
	createSaveLink $simLinkPath $emuSavePath

	$simLinkPath = "$emusPath\citron\user\nand\system\save\8000000000000010\su\avators"
	$emuSavePath = "$emulationPath\saves\citron\profiles"
	createSaveLink $simLinkPath $emuSavePath

    if ($verbose) { Write-Host "citron save setup complete.`n" -ForegroundColor Green }	
}

#Dolphin - Gamecube
function Dolphin_setupSaves() {
	if ($verbose) { Write-Host "`n===== Setting up Dolphin saves =====" -ForegroundColor Magenta }

	#Saves GC
	$simLinkPath = "$emusPath\Dolphin-x64\User\GC"
	$emuSavePath = "$emulationPath\saves\dolphin\GC"
	createSaveLink $simLinkPath $emuSavePath

	#Saves Wii
	$simLinkPath = "$emusPath\Dolphin-x64\User\Wii"
	$emuSavePath = "$emulationPath\saves\dolphin\Wii"
	createSaveLink $simLinkPath $emuSavePath


	#States
	$simLinkPath = "$emusPath\Dolphin-x64\User\StateSaves"
	$emuSavePath = "$emulationPath\saves\dolphin\states"
	createSaveLink $simLinkPath $emuSavePath

    if ($verbose) { Write-Host "Dolphin save setup complete.`n" -ForegroundColor Green }	
}

#Duckstation - PS1
function Duckstation_setupSaves() {
	if ($verbose) { Write-Host "`n===== Setting up duckstation saves =====" -ForegroundColor Magenta }

	#Saves
	$simLinkPath = "$emusPath\duckstation\memcards"
	$emuSavePath = "$emulationPath\saves\duckstation\saves"
	createSaveLink $simLinkPath $emuSavePath

	#States
	$simLinkPath = "$emusPath\duckstation\savestates"
	$emuSavePath = "$emulationPath\saves\duckstation\states"
	createSaveLink $simLinkPath $emuSavePath

    if ($verbose) { Write-Host "duckstation save setup complete.`n" -ForegroundColor Green }	
}

#Flycast - Dreamcast
function Flycast_setupSaves() {
	if ($verbose) { Write-Host "`n===== Setting up Flycast saves =====" -ForegroundColor Magenta }

	#Saves
	$simLinkPath = "$emusPath\flycast\data"
	$emuSavePath = "$emulationPath\saves\flycast\saves"
	createSaveLink $simLinkPath $emuSavePath

    if ($verbose) { Write-Host "Flycast save setup complete.`n" -ForegroundColor Green }	
}

#lime3ds - 3DS
function Lime3DS_setupSaves(){
	if ($verbose) { Write-Host "`n===== Setting up lime3ds saves =====" -ForegroundColor Magenta }
	
	$simLinkPath = "$emusPath\lime3ds\user\sdmc"
	$emuSavePath = "$emulationPath\saves\lime3ds\saves"
	createSaveLink $simLinkPath $emuSavePath

	$simLinkPath = "$emusPath\lime3ds\user\states"
	$emuSavePath = "$emulationPath\saves\lime3ds\states"
	createSaveLink $simLinkPath $emuSavePath

    if ($verbose) { Write-Host "lime3ds save setup complete.`n" -ForegroundColor Green }	
}

#MAME
function MAME_setupSaves() {
	if ($verbose) { Write-Host "`n===== Setting up MAME saves =====" -ForegroundColor Magenta }

    $simLinkPath = "$emusPath\mame\saves"
    $emuSavePath = "$emulationPath\saves\mame\saves"
    createSaveLink $simLinkPath $emuSavePath
	
	$simLinkPath = "$emusPath\mame\states"
    $emuSavePath = "$emulationPath\saves\mame\states"
    createSaveLink $simLinkPath $emuSavePath

    if ($verbose) { Write-Host "MAME save setup complete.`n" -ForegroundColor Green }	
}

#m2emulator - Sega Model 2?

#MelonDS - DS
function MelonDS_setupSaves() {
	if ($verbose) { Write-Host "`n===== Setting up MelonDS saves =====" -ForegroundColor Magenta }

    $simLinkPath = "$emusPath\melonds\saves"
    $emuSavePath = "$emulationPath\saves\melonds\saves"
    createSaveLink $simLinkPath $emuSavePath
	
	$simLinkPath = "$emusPath\melonds\states"
    $emuSavePath = "$emulationPath\saves\melonds\states"
    createSaveLink $simLinkPath $emuSavePath

    if ($verbose) { Write-Host "MelonDS save setup complete.`n" -ForegroundColor Green }	
}

#mGBA - GBA
function mGBA_setupSaves() {
	if ($verbose) { Write-Host "`n===== Setting up mGBA saves =====" -ForegroundColor Magenta }

    $simLinkPath = "$emusPath\mGBA\saves"
    $emuSavePath = "$emulationPath\saves\mGBA\saves"
    createSaveLink $simLinkPath $emuSavePath
	
	$simLinkPath = "$emusPath\mGBA\states"
    $emuSavePath = "$emulationPath\saves\mGBA\states"
    createSaveLink $simLinkPath $emuSavePath

    if ($verbose) { Write-Host "mGBA save setup complete.`n" -ForegroundColor Green }	
}

#PCSX2 - PS2
function PCSX2_setupSaves() {
	if ($verbose) { Write-Host "`n===== Setting up PCSX2 saves =====" -ForegroundColor Magenta }

	#memcards
	$simLinkPath = "$emusPath\PCSX2-Qt\memcards"
	$emuSavePath = "$emulationPath\saves\pcsx2\saves"
	createSaveLink $simLinkPath $emuSavePath

	#States
	$simLinkPath = "$emusPath\PCSX2-Qt\sstates"
	$emuSavePath = "$emulationPath\saves\pcsx2\states"
	createSaveLink $simLinkPath $emuSavePath

    if ($verbose) { Write-Host "PCSX2 save setup complete.`n" -ForegroundColor Green }	
}

#PPSSPP - PSP
function PPSSPP_setupSaves() {
	if ($verbose) { Write-Host "`n===== Setting up PPSSPP saves =====" -ForegroundColor Magenta }

	$simLinkPath = "$emusPath\PPSSPP\memstick\PSP\PPSSPP_STATE"
	$emuSavePath = "$emulationPath\saves\ppsspp\states"
	createSaveLink $simLinkPath $emuSavePath

	$simLinkPath = "$emusPath\PPSSPP\memstick\PSP\SAVEDATA"
	$emuSavePath = "$emulationPath\saves\ppsspp\saves"
	createSaveLink $simLinkPath $emuSavePath

    if ($verbose) { Write-Host "PPSSPP save setup complete.`n" -ForegroundColor Green }	
}

#Primehack - Wii Metroid
function Primehack_setupSaves() {
	if ($verbose) { Write-Host "`n===== Setting up Primehack saves =====" -ForegroundColor Magenta }

	$simLinkPath = "$emusPath\primehack\User\GC"
	$emuSavePath = "$emulationPath\saves\primehack\GC"
	createSaveLink $simLinkPath $emuSavePath

	#Saves Wii
	$simLinkPath = "$emusPath\primehack\User\Wii"
	$emuSavePath = "$emulationPath\saves\primehack\Wii"
	createSaveLink $simLinkPath $emuSavePath

	#States
	$simLinkPath = "$emusPath\primehack\User\StateSaves"
	$emuSavePath = "$emulationPath\saves\primehack\states"
	createSaveLink $simLinkPath $emuSavePath

    if ($verbose) { Write-Host "Primehack save setup complete.`n" -ForegroundColor Green }	
}

#Retroarch - Multi system 
function Retroarch_setupSaves() {
	if ($verbose) { Write-Host "`n===== Setting up Retroarch saves =====" -ForegroundColor Magenta }

	#Saves
	$simLinkPath = "$emusPath\RetroArch-Win64\saves"
	$emuSavePath = "$emulationPath\saves\retroarch\saves"
	createSaveLink "$simLinkPath" "$emuSavePath"

	#States
	$simLinkPath = "$emusPath\RetroArch-Win64\states"
	$emuSavePath = "$emulationPath\saves\retroarch\states"
	createSaveLink "$simLinkPath" "$emuSavePath"

    if ($verbose) { Write-Host "Retroarch save setup complete.`n" -ForegroundColor Green }	
}

#RPCS3 - PS3
function RPCS3_setupSaves() {
	if ($verbose) { Write-Host "`n===== Setting up RPCS3 saves =====" -ForegroundColor Magenta }

	$simLinkPath = "$emusPath\rpcs3\dev_hdd0\home\00000001\savedata"
	$emuSavePath = "$emulationPath\saves\rpcs3\saves"
	createSaveLink $simLinkPath $emuSavePath
	
	$simLinkPath = "$emusPath\rpcs3\dev_hdd0\home\00000001\trophy"
	$emuSavePath = "$emulationPath\saves\rpcs3\trophy"
	createSaveLink $simLinkPath $emuSavePath

    if ($verbose) { Write-Host "RPCS3 save setup complete.`n" -ForegroundColor Green }	
}

#ryujinx - switch 
function Ryujinx_setupSaves() {
	if ($verbose) { Write-Host "`n===== Setting up ryujinx saves =====" -ForegroundColor Magenta }

	$simLinkPath = "$emusPath\Ryujinx\portable\bis\user\save"
	$emuSavePath = "$emulationPath\saves\ryujinx\saves"
	createSaveLink $simLinkPath $emuSavePath

	$simLinkPath = "$emusPath\Ryujinx\portable\bis\system\save"
	$emuSavePath = "$emulationPath\saves\ryujinx\system_saves"
	createSaveLink $simLinkPath $emuSavePath

	$simLinkPath = "$emusPath\Ryujinx\portable\bis\user\saveMeta"
	$emuSavePath = "$emulationPath\saves\ryujinx\saveMeta"
	createSaveLink $simLinkPath $emuSavePath

	$simLinkPath = "$emusPath\Ryujinx\portable\system"
	$emuSavePath = "$emulationPath\saves\ryujinx\system"
	createSaveLink $simLinkPath $emuSavePath

    if ($verbose) { Write-Host "ryujinx save setup complete.`n" -ForegroundColor Green }	
}

#Scummvm - Scummvm
function Scummvm_setupSaves() {
	if ($verbose) { Write-Host "`n===== Setting up Scummvm saves =====" -ForegroundColor Magenta }

	$simLinkPath = "$emusPath\scummvm\Saved games"
	$emuSavePath = "$emulationPath\saves\scummvm\saves"
	createSaveLink $simLinkPath $emuSavePath

    if ($verbose) { Write-Host "Scummvm save setup complete.`n" -ForegroundColor Green }	
}

#Shadps4 - PS4
function Shadps4_setupSaves() {
	if ($verbose) { Write-Host "`n===== Setting up Shadps4 saves =====" -ForegroundColor Magenta }

	$simLinkPath = "$emusPath\shadPS4\user\savedata"
	$emuSavePath = "$emulationPath\saves\shadps4\saves"
	createSaveLink $simLinkPath $emuSavePath

    if ($verbose) { Write-Host "Shadps4 save setup complete.`n" -ForegroundColor Green }	
}

#supermodel - SEGA Model 3
function Supermodel_setupSaves() {
	if ($verbose) { Write-Host "`n===== Setting up supermodel saves =====" -ForegroundColor Magenta }

    $simLinkPath = "$emusPath\Supermodel\saves"
    $emuSavePath = "$emulationPath\saves\supermodel\saves"
    createSaveLink $simLinkPath $emuSavePath

    if ($verbose) { Write-Host "supermodel save setup complete.`n" -ForegroundColor Green }	
}

#Vita3K - PSVita
function Vita3K_setupSaves() {
	if ($verbose) { Write-Host "`n===== Setting up Vita3K saves =====" -ForegroundColor Magenta }

    $simLinkPath = "$emusPath\Vita3K\storage\ux0\user\00\savedata"
    $emuSavePath = "$emulationPath\saves\Vita3K\saves"
	createSaveLink $simLinkPath $emuSavePath

    if ($verbose) { Write-Host "Vita3K save setup complete.`n" -ForegroundColor Green }	
}

#Xemu - Xbox
function Xemu_setupSaves() {
	if ($verbose) { Write-Host "`n===== Setting up Xemu saves =====" -ForegroundColor Magenta }

    $simLinkPath = "$emusPath\xemu\storage"
    $emuSavePath = "$emulationPath\saves\xemu\saves"
    createSaveLink $simLinkPath $emuSavePath

    if ($verbose) { Write-Host "Xemu save setup complete.`n" -ForegroundColor Green }	
}

#Xenia - Xbox 360
function Xenia_setupSaves() {
	if ($verbose) { Write-Host "`n===== Setting up Xenia saves =====" -ForegroundColor Magenta }

	$simLinkPath = "$emusPath\xenia_canary\content"
	$emuSavePath = "$emulationPath\saves\xenia\saves"
	createSaveLink $simLinkPath $emuSavePath

    if ($verbose) { Write-Host "Xenia save setup complete.`n" -ForegroundColor Green }	
}

#yuzu - Switch 
function Yuzu_setupSaves() {
	if ($verbose) { Write-Host "`n===== Setting up yuzu saves =====" -ForegroundColor Magenta }

	$simLinkPath = "$emusPath\yuzu\user\nand\user\save"
	$emuSavePath = "$emulationPath\saves\yuzu\saves"
	createSaveLink $simLinkPath $emuSavePath

	$simLinkPath = "$emusPath\yuzu\user\nand\system\save\8000000000000010\su\avators"
	$emuSavePath = "$emulationPath\saves\yuzu\profiles"
	createSaveLink $simLinkPath $emuSavePath

    if ($verbose) { Write-Host "yuzu save setup complete.`n" -ForegroundColor Green }	
}

#Launch all symlink functions:

Azahar_setupSaves

BigPEmu_setupSaves

Cemu_setupSaves

Citra_setupSaves

Citron_setupSaves

Dolphin_setupSaves

Duckstation_setupSaves

Flycast_setupSaves

Lime3DS_setupSaves

MAME_setupSaves

MelonDS_setupSaves

mGBA_setupSaves

PCSX2_setupSaves

PPSSPP_setupSaves

Primehack_setupSaves

Retroarch_setupSaves

RPCS3_setupSaves

Scummvm_setupSaves

Supermodel_setupSaves

Ryujinx_setupSaves

Vita3K_setupSaves

Xemu_setupSaves

Xenia_setupSaves

Yuzu_setupSaves
