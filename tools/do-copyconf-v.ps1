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

# Exemple d'utilisation
$pathsToCopy = @(
  
    "$emuPath\azahar\user\config\*"
	"$emuPath\BigPEmu\config\BigPEmuConfig.bigpcfg"
	"$emuPath\cemu\settings.xml"
    "$emuPath\cemu\controllerProfiles\*"
   
)

foreach ($p in $pathsToCopy) {
	if ($verbose) { Write-Host "`n===== Setting up  $p =====" -ForegroundColor Magenta }
    Copy-EmuConfig $p
	 if ($verbose) { Write-Host " $p setup complete.`n" -ForegroundColor Green }
}
