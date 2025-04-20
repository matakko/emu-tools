

$esdePath = "D:\Emulation\Emulators\EmulationStation-DE\ES-DE" 
$toolsPath = "D:\Emulation\tools"

function createSaveLink($target, $linkPath) {
	
	New-Item -ItemType SymbolicLink -Path $linkPath -Target $target 
}

function ES-DE_setupsymlink(){

	$simLinkPath = "$esdePath"
	$emuSavePath = "$toolsPath\ES-DE"
	createSaveLink $simLinkPath $emuSavePath


}

ES-DE_setupsymlink
