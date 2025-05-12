$firstline = "C: "

$FFMPEGRemovePopups =  "-hide_banner -y"
$resources = "./SpriteResources"
$fontcolor = "#a8a8a8"
$fontsize = "16"
$output = "output.gif"
$tempfile = ".tmp"
$textx = "130"
$texty = "15"
$maxline = 10000 # how many characters per line


if (Test-Path $tempfile) {Remove-Item $tempfile}

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


[Array]$spritedirs =
    "Background/TV/Edges/TV Edges",
    "Background/Scanlines/RGB Scanlines",
    "Background/Vignette/Vignette",
    "Head/Tilted/Eyes/Closed/Eyes Tilted Closed",
    "Head/Tilted/Mouth/Neutral/Neutral Tilted",
    "Head/Tilted/Head Tilted",
    "Body/Default/RH Out/RH Out",
    "Body/Default/Default",
    "Background/GUI/GUI",
    "Background/Tetras/Neon Tetras RH",
    "Background/Bg/BG"

y
$i = 0
$inputsprites = "-i " + """$(Join-Path -Path $resources -ChildPath $spritedirs[$i])" + "_sprite_%02d.png"" "
$combined = "[$i]null[comb$($i+1)];"
for ($i=1; $i -le $spritedirs.Length-1; $i++) {
    $inputsprites += "-i " + """$(Join-Path -Path $resources -ChildPath $spritedirs[$i])" + "_sprite_%02d.png"" "
    $combined += "[$i][comb$i]overlay[comb$($i+1)];"
}
$combined += "[comb$i]null[complete]"

$addtext = "[complete]" + ((
    "drawtext=fontfile=Perfect DOS VGA 437 Win.ttf",
    "fontsize=$fontsize",
    "fontcolor=$fontcolor",
    "x=$textx",
    "y=$texty",
    "textfile=$tempfile"
) -join (":")) + "[withtext]"

$fixpalette = "[withtext]split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse"

$completefilter = ($combined,$addtext,$fixpalette) -join(";")
#"[1][0] overlay [d]; [d]split [e][f]; [f]palettegen=reserve_transparent=on [p2];[e][p2] paletteuse"

$completeargs = @(
    "$FFMPEGRemovePopups",
    "$inputsprites",
    "-filter_complex",
    """$completefilter""",
    "-r 80",
    "$output"
) -join (" ") -split ("(?>`"(?: *)?(.*?)`"| )") | Where-Object {$_ -ne ""}

$completeargs
pause

& ffmpeg.exe $completeargs 

Remove-Item $tempfile