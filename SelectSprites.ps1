$resources = Resolve-Path "SpriteResources"

function List-Options {

    param (
        [Array]$arr
    )

    Write-Output "0 - Return"
    for ($i=1; $i -le $arr.Length; $i++) {
        Write-Output "$i - $($arr[$i-1])"
    }
}

$curfolder = $resources
while ($true) {
    $active = Get-ChildItem $curfolder -Directory
    List-Options $active
    $usrinput = Read-Host "Choose"
    if ($usrinput -eq 0) {
        if ($curfolder -eq $resources) {break}
        else {$curfolder = (Split-Path $curfolder -Parent -Resolve); echo $curfolder}
    }
    else {
        if ($usrinput -le $active.Length) {
            $curfolder = Join-Path -Path $curfolder -ChildPath $active[$usrinput-1]
        }
        else {
            Write-Output "Error: invalid choice. try again"
        }
    }
}
