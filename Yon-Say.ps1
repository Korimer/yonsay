$resources = "./SpriteResources"
$fontcolor = "#a8a8a8"
$fontsize = "20"
$bggif = "yon.gif"
$output = "output.gif"
$textx = "130"
$texty = "20"

$maxline = 69 # how many characters per line
$firstline = "C:  "
$tempfile = ".tmp"

if (Test-Path $tempfile) {Remove-Item $tempfile}

$background = Join-Path -Path $resources -ChildPath $bggif -Resolve
$indent = " " * $firstline.Length

$basetext = Read-Host -Prompt "Yon says"

# WIP
# $splittext = (($basetext -split "( )") -replace "\\n","`n") -split ""

# $replacementmap = [ordered]@{
#     "\\" = "\\"
#     " +" = '$1'
#     "(\\n|\n)" = "`n"+$indent
# }

$chrcnt = 0
Out-File -Filepath $tempfile -InputObject $firstline -NoNewline -Encoding utf8
foreach ($line in ($basetext -split "( )")) {
    $escapedtext = ($line -replace '\\','\\') -replace "(\\n|`n)", ("`n"+$indent)
    $chrcnt += $line.Length 
    if ($chrcnt -gt $maxline) {
        Out-File -FilePath $tempfile -Append -InputObject ("`n" + $indent) -NoNewline -Encoding utf8
        $chrcnt = 0
    }
    Out-File -FilePath $tempfile -Append -InputObject $escapedtext -NoNewline -Encoding utf8
}

$addtext = (
    "drawtext=fontfile=""Kiwi Fruit.otf""",
    "fontsize=$fontsize",
    "fontcolor=$fontcolor",
    "x=$textx",
    "y=$texty",
    """textfile=$tempfile"""
) -join (":")

$fixpalette = "split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse"

[Array]$spritedirs = 
    "Head/Tilting/Head_Tilt",
    "Body/Default"

$selectedsprites = foreach ($spritecomb in $spritedirs) {
    (Join-Path -Path $resources -ChildPath $spritecomb).ToString() + "_Sprite_%02d.png"
}

$completefilter = ($addtext,$fixpalette) -join(",")
#"[1][0] overlay [d]; [d]split [e][f]; [f]palettegen=reserve_transparent=on [p2];[e][p2] paletteuse"

[Array]$completeargs =
    "-i",
    "$background",
    "-vf",
    "$completefilter",
    "$output"

& ffmpeg.exe $completeargs 

Remove-Item $tempfile