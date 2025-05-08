while ($true) {

	$strtomatch = (Read-Host -Prompt "regex name") + "_sprite_\d+\.png"
	$fldrtomove = Read-Host -Prompt "where should it go?"
	New-Item -ItemType Directory -Force -Path $fldrtomove
	Get-Childitem "." | Where-Object {$_.Name -match $strtomatch} | Move-Item -Destination $fldrtomove
}