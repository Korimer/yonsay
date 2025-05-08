$resources = "./"
$fontcolor = "#a8a8a8"
$fontsize = "20"
$bggif = "yon.gif"
$output = "output.gif"
$textx = "130"
$texty = "20"

$maxline = 69 # how many characters per line
$firstline = "C:  "
$tempfile = ".tmp"

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

$textcommand = (
    "drawtext=fontfile=""Kiwi Fruit.otf""",
    "fontsize=$fontsize",
    "fontcolor=$fontcolor",
    "x=$textx",
    "y=$texty",
    """textfile=$tempfile"""
) -join (":")
$filtercommand = "split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse"

$completefilter = ($textcommand,$filtercommand) -join(",")

[Array]$completeargs =
    "-i",
    "$background",
    "-vf",
    "$completefilter",
    "$output"

& ffmpeg.exe $completeargs 

Remove-Item $tempfile