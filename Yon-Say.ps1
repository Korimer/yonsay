$firstline = "C:  "

$FFMPEGRemovePopups =  "-hide_banner -y"
$resources = "./SpriteResources"
$fontcolor = "#a8a8a8"
$fontsize = "20"
$output = "output.gif"
$tempfile = ".tmp"
$textx = "130"
$texty = "20"
$maxline = 69 # how many characters per line


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
    "Background/Scanlines/RGB Scanlines",
    "Background/Vignette/Vignette",
    "Head/Bouncing/Head Bounce",
    "Body/Default_Hands_Hidden/Default Hands Hidden",
    "Background/GUI/GUI",
    "Background/Bg/BG",
    "Background/TV/Edges/TV Edges"


$i = 0
$inputsprites = "-i " + """$(Join-Path -Path $resources -ChildPath $spritedirs[$i])" + "_sprite_%02d.png"" "
$combined = "[$i]null[comb$($i+1)];"
for ($i=1; $i -le $spritedirs.Length-1; $i++) {
    $inputsprites += "-i " + """$(Join-Path -Path $resources -ChildPath $spritedirs[$i])" + "_sprite_%02d.png"" "
    $combined += "[$i][comb$i]overlay[comb$($i+1)];"
}
$combined += "[comb$i]null[complete]"

$addtext = "[complete]" + ((
    "drawtext=fontfile=Kiwi.otf",
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
    """",
    "$completefilter",
    """",
    "$output"
) -join (" ") -split ("(?>`"(?: *)?(.*?)`"| )") | Where-Object {$_ -ne ""}

$completeargs
Pause
# aiming for 
# ffmpeg -v warning -hide_banner -i ".\SpriteResources\Head\Tilting\Head Tilt_Sprite_%02d.png" -i ".\SpriteResources\Body\Default\Default_sprite_%02d.png"  -filter_complex "[0]null[comb1];[1][comb1]overlay[comb2];[comb2]null[complete];[complete]drawtext=fontfile=Kiwi.otf:fontsize=20:fontcolor=#a8a8a8:x=130:y=20:textfile=layer_key.txt[withtext];[withtext]split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" output.gif
& ffmpeg.exe $completeargs 

Remove-Item $tempfile