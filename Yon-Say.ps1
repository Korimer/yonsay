$resources = "./"
$fontcolor = "#a8a8a8"
$fontsize = "20"
$bggif = "yon.gif"
$output = "output.gif"
$textx = "130"
$texty = "20"

$maxline = 70 # how many characters per line
$firstline = "C:  "
$outfile = ".tmp"

$background = Join-Path -Path $resources -ChildPath $bggif -Resolve
$indent = " " * $firstline.Length
$escapedfirst = ($firstline -replace '(?<Escape>[,:"\\])','\${Escape}')-replace '\\', '\\'

$basetext = Read-Host -Prompt "Yon says"

$chrcnt = 0
$fnltxt = $escapedfirst
foreach ($line in ($basetext -split "( )")) {
    $escapedtext = ($line -replace '(?<Escape>[,:"\\])','\${Escape}') -replace '\\\\', ("\"*8)
    echo $escapedtext
    $chrcnt += $line.Length 
    if ($chrcnt -gt $maxline) {
        $fnltxt += "`n" + $indent
        $chrcnt = 0
    }
    $fnltxt += $escapedtext
}

$ffmpegcommand = (
    "drawtext=fontfile=""Kiwi Fruit.otf""",
    "fontsize=$fontsize",
    "fontcolor=$fontcolor",
    "x=$textx",
    "y=$texty",
    """text=$fnltxt"""
) -join (":")

[Array]$imgargs =
    "-i",
    "$background",
    "-vf",
    $ffmpegcommand,
    "$output"

& ffmpeg.exe $imgargs