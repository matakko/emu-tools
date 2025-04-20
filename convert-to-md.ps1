$folderPath = "Folder PATH"


# Scan folder and give .md at every file because why not ? 
Get-ChildItem -Path $folderPath -Recurse -File | ForEach-Object {
    $newName = $_.FullName + ".md"
    Rename-Item -Path $_.FullName -NewName $newName
    Write-Host "Renommé : $($_.FullName) -> $newName"
}

