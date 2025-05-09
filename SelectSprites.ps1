$resources = Resolve-Path "SpriteResources"

$active = $null
while ($true) {
    $active = Get-ChildItem $resources -Directory
    $active
    break
}