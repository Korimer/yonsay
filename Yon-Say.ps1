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

$basetext = Read-Host -Prompt "Yon says"

$chrcnt = 0
Out-File -Filepath $outfile -InputObject $firstline -NoNewline -Encoding utf8
foreach ($line in ($basetext -split "( )")) {
    $escapedtext = $line -replace '\\','\\'
    $chrcnt += $line.Length 
    if ($chrcnt -gt $maxline) {
        Out-File -FilePath $outfile -Append -InputObject ("`n" + $indent) -NoNewline -Encoding utf8
        $chrcnt = 0
    }
    Out-File -FilePath $outfile -Append -InputObject $escapedtext -NoNewline -Encoding utf8
}

$ffmpegcommand = (
    "drawtext=fontfile=""Kiwi Fruit.otf""",
    "fontsize=$fontsize",
    "fontcolor=$fontcolor",
    "x=$textx",
    "y=$texty",
    """textfile=$outfile"""
) -join (":")

[Array]$imgargs =
    "-i",
    "$background",
    "-vf",
    $ffmpegcommand,
    "$output"

& ffmpeg.exe $imgargs