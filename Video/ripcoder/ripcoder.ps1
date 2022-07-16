## RIPCODER
#
##### A Powershell script stealing everything it can from RipBot264
#
#Ends goal gives RipBot264 GUI a CLI interface, plus a few bells and whistles like it normalizes the main audio file (and keeps original) and it creates at SRT from a SUP.
#
#It is tailored to completely max out a CPU (I using a AMD 5950x), just using x264 would only use like 60% so here we are
#
#**Requirements** 
#
#  RipBot264v1.26.0 https://forum.doom9.org/showthread.php?t=127611  
#  Subtitle Edit https://github.com/SubtitleEdit/subtitleedit/releases  
#  MediaInfo CLI VERSION https://mediaarea.net/en/MediaInfo/Download/Windows  
#
# YOU NEED TO SET 3 VARIABLES, SEE LINE 229 in script
#
# **Basic Usage**
#
# ripcoder file [Path to file] 
#
##### Main Options  
#
######  Audio normalizion Options  
#
#      -codec ac3 [Audio for normalized file, **ac3** is default]
#      -audioext ac3 [File extension for selected codec, **ac3** is default]
#      -bitrate 192k [Audio file bitrate, **192k** is default]
#      -freq 48000 [Audio file frequency , **48000** is default]
#
######  Video Options  
#
#      -crf 20 [Constant Rate Factor, range 0 to 51, default is **20** ]  
#      -level 4.0 [Options 1.0, 1.1, 1.2, 1.3, 2.0, 2.1, 2.2, 3.0, 3.1, 3.2, 4.0, 4.1, 4.2, 5.0, & 5.1. Default is **4.0**]  
#      -preset veryslow [Options ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow, & placebo. Default is **veryslow**]  
#      -myprofile high [Options baseline, main, & high. Default is **high**]  
#      -tune none [Options none, film, animation, grain, stillimage, psnr, ssim, fastdecode, & zerolatency. Default is **none**]  
#
######  Extra Options  
#
######  Resizing  
#
#      -s2160 [Resize to 2160p]  
#      -s1080 [Resize to 1080p]   
#      -s720 [Resize to 720p]  
#      -s576 [Resize to 576p]  
#      -s480 [Resize to 480p]   
#
#######   Cropping  
#
#      -autocrop [Audio crop black bars]  
#      -crop 'left,top,right,bottom' [Number of pixels to remove from listed direction, must be power of 2 (0 2 4 6 8 10 etc) (EX -crop '265,2,265,0'  )]  
#
#######   Audio  
#
#      -skipnorm [Don't normalize audio]  
#      -onlynorm [only include normalized audio file, main audio track removed]  
#      -Maxaudio [Total number of audio files to include in final video, 9 is default)  
#
#######   Color Convertion   
#
#      -LPC [TV -> PC]  
#      -LTV [PC -> TV]  
#      -colors 'hue,sat,bright,cont' [Hue -180 to 180 Whole Numbers, sat 0 to 2 by tenths,bright -255 to 255 Whole Numbers,cont  0 to 2 by tenths (EX -crop '265,2,265,0' )]  
#
#######   Video Enhancements  
#
#      -decimate [decimate 29.97 to 23.976]  
#      -tonemap [Kepp HDR tone map]  
#      -addborders [Auto Borders for 16/9]  
#      -interlace [Interlaces video (why?)]  
#
#######      Sharpen  
#
#      -sh25 [Sharpen 25%]  
#      -sh50 [Sharpen 50%]  
#      -sh75 [Sharpen 75%]  
#      -sh100 [Sharpen 100%]  
#
#######      Degrain  
#
#      -mdegrain1 400 [Denoise using MDegrain1, they value is for strength 100-800]  
#      -mdegrain2 400 [Denoise using MDegrain2, they value is for strength 100-800]  
#      -mdegrain3 400 [Denoise using MDegrain3, they value is for strength 100-800]  
#
#######      Deinterlace  
#
#      -IT [Inverse Telecine]  
#      -dBFF1x [BFF keep same frame rate]  
#      -dBFF2x [BFF double frame rate]  
#      -dTFF1x [TFF keep same frame rate]  
#      -dTFF2x [TFF double frame rate]  
# Examples
#  ripcoder "C:\Vi deo\P&R\s02e15.mkv" -crf 16 -preset veryslow -profile main
#
Param(
    [parameter(Mandatory = $true)]
    [alias("f")]
    $File,
    [parameter(Mandatory = $false)]
    [String]$codec = "ac3",
    [parameter(Mandatory = $false)]
    [String]$audioext = "ac3" ,
    [parameter(Mandatory = $false)]
    [String]$bitrate = "384k",
    [parameter(Mandatory = $false)]
    [String]$freq = "48000",
    [parameter(Mandatory = $false)]
    [String]$crf = "20",
    [parameter(Mandatory = $false)]
    [String]$level = "4.1" ,
    [parameter(Mandatory = $false)]
    [String]$preset = "veryslow",
    [parameter(Mandatory = $false)]
    [Alias('profile')]
    [String]$myprofile = "high",
    [parameter(Mandatory = $false)]
    [String]$tune = "none",
    [parameter(Mandatory = $false)]
    [Switch]$skipnorm = $false,
    [parameter(Mandatory = $false)]
    [Switch]$onlynorm = $false,
    [parameter(Mandatory = $false)]
    [Int64]$Maxaudio = 9,
    [parameter(Mandatory = $false)]
    [Switch]$s720 = $false,
    [parameter(Mandatory = $false)]
    [Switch]$LPC = $false,
    [parameter(Mandatory = $false)]
    [Switch]$LTV = $false,
    [parameter(Mandatory = $false)]
    [String]$colors = $false,
    [parameter(Mandatory = $false)]
    [String]$crop = $false,
    [parameter(Mandatory = $false)]
    [Switch]$IT = $false,
    [parameter(Mandatory = $false)]
    [Switch]$s2160 = $false,
    [parameter(Mandatory = $false)]
    [Switch]$s1080 = $false,
    [parameter(Mandatory = $false)]
    [Switch]$s576 = $false,
    [parameter(Mandatory = $false)]
    [Switch]$s480 = $false,
    [parameter(Mandatory = $false)]
    [Switch]$tonemap = $false,
    [parameter(Mandatory = $false)]
    [Switch]$sh25 = $false,
    [parameter(Mandatory = $false)]
    [Switch]$sh50 = $false,
    [parameter(Mandatory = $false)]
    [Switch]$sh75 = $false,
    [parameter(Mandatory = $false)]
    [Switch]$sh100 = $false,
    [parameter(Mandatory = $false)]
    [Switch]$Decimate = $false,
    [parameter(Mandatory = $false)]
    [String]$mdegrain1 = $false,
    [parameter(Mandatory = $false)]
    [String]$mdegrain2 = $false,
    [parameter(Mandatory = $false)]
    [String]$mdegrain3 = $false,
    [parameter(Mandatory = $false)]
    [Switch]$addborders = $false,
    [parameter(Mandatory = $false)]
    [Switch]$interlace = $false,
    [parameter(Mandatory = $false)]
    [Switch]$dBFF2x = $false,
    [parameter(Mandatory = $false)]
    [Switch]$dBFF1x = $false,
    [parameter(Mandatory = $false)]
    [Switch]$dTFF2x = $false,
    [parameter(Mandatory = $false)]
    [Switch]$dTFF1x = $false,
    [parameter(Mandatory = $false)]
    [Switch]$autocrop = $false
)
Switch ($tune){
    "none" {$tune = ""}
    "film" {$tune = "--tune film "}
    "animation" {$tune = "--tune animation "}
    "grain" {$tune = "--tune grain "}
    "stillimage" {$tune = "--tune stillimage "}
    "psnr" {$tune = "--tune psnr "}
    "ssim" {$tune = "--tune ssim "}
    "fastdecode" {$tune = "--tune fastdecode "}
    "zerolatency" {$tune = "--tune zerolatency "}
    default {$tune = ""}
}
Switch ($level){
    "1.0" {$level = "--level 1.0 --aud --nal-hrd vbr --vbv-bufsize 80 --vbv-maxrate 80 "}
    "1.1" {$level = "--level 1.1 --aud --nal-hrd vbr --vbv-bufsize 240 --vbv-maxrate 240 "}
    "1.2" {$level = "--level 1.2 --aud --nal-hrd vbr --vbv-bufsize 480 --vbv-maxrate 480 "}
    "1.3" {$level = "--level 1.3 --aud --nal-hrd vbr --vbv-bufsize 960 --vbv-maxrate 960 "}
    "2.0" {$level = "--level 2.0 --aud --nal-hrd vbr --vbv-bufsize 2500 --vbv-maxrate 2500 "}
    "2.1" {$level = "--level 2.1 --aud --nal-hrd vbr --vbv-bufsize 5000 --vbv-maxrate 5000 "}
    "2.2" {$level = "--level 2.2 --aud --nal-hrd vbr --vbv-bufsize 5000 --vbv-maxrate 5000 "}
    "3.0" {$level = "--level 3.0 --aud --nal-hrd vbr --vbv-bufsize 12500 --vbv-maxrate 12500 "}
    "3.1" {$level = "--level 3.1 --aud --nal-hrd vbr --vbv-bufsize 17500 --vbv-maxrate 17500 "}
    "3.2" {$level = "--level 3.2 --aud --nal-hrd vbr --vbv-bufsize 25000 --vbv-maxrate 25000 "}
    "4.0" {$level = "--level 4.0 --aud --nal-hrd vbr --vbv-bufsize 25000 --vbv-maxrate 25000 "}
    "4.1" {$level = "--level 4.1 --aud --nal-hrd vbr --vbv-bufsize 62500 --vbv-maxrate 62500 "}
    "4.2" {$level = "--level 4.2 --aud --nal-hrd vbr --vbv-bufsize 62500 --vbv-maxrate 62500 "}
    "5.0" {$level = "--level 5.0 --aud --nal-hrd vbr --vbv-bufsize 168750 --vbv-maxrate 168750 "}
    "5.1" {$level = "--level 5.1 --aud --nal-hrd vbr --vbv-bufsize 300000 --vbv-maxrate 300000 "}
    "5.2" {$level = "--level 5.2 --aud --nal-hrd vbr --vbv-bufsize 300000 --vbv-maxrate 300000 "}
    default {$level = "--level 4.0 --aud --nal-hrd vbr --vbv-bufsize 25000 --vbv-maxrate 25000 "}
}
Switch ($myprofile){
    "baseline" {$myprofile = "--profile baseline "}
    "main" {$myprofile = "--profile main "}
    "high" {$myprofile = "--profile high "}
    "high10" {$myprofile = "--profile high10 --output-depth 10 "}
    "high422" {$myprofile = "--profile high422 "} 
    "high444" {$myprofile = "--profile high444 "}
    default {$myprofile = "--profile high "}
}
switch ($preset) {
    "ultrafast" {$preset = "--preset ultrafast "}
    "superfast" {$preset = "--preset superfast "}
    "veryfast" {$preset = "--preset veryfast "}
    "faster" {$preset = "--preset faster "}
    "fast" {$preset = "--preset fast "}
    "slow" {$preset = "--preset slow "}
    "slower" {$preset = "--preset slower "}
    "veryslow" {$preset = "--preset veryslow "}
    "placebo" {$preset = "--preset placebo "}
    Default {$preset = "--preset fast "}
}
###########################  SET THESE  #################################

$RipBot264PATH = "c:\tools\RipBot264v1.26.0" #https://forum.doom9.org/showthread.php?t=127611
$SubtitleEdit = "C:\tools\SubtitleEdit\SubtitleEdit.exe" #https://github.com/SubtitleEdit/subtitleedit/releases
$mediainfo = 'C:\tools\MediaInfo_CLI\MediaInfo.exe' #CLI VERSION https://mediaarea.net/en/MediaInfo/Download/Windows

##########################################################################

$EncodingClient = ($RipBot264PATH + '\EncodingClient.exe')
$EncodingServer = ($RipBot264PATH + '\EncodingServer.exe')
$File = Get-ChildItem -Path $File
$path = $File.DirectoryName
$ffprobe = ($RipBot264PATH + '\Tools\ffmpeg\bin\ffprobe.exe')
$ffmpeg = ($RipBot264PATH + '\Tools\ffmpeg\bin\ffmpeg.exe')
$detectcrop = ($RipBot264PATH + '\Tools\DetectBorders\DetectBorders.exe')
$temppath = "c:\Temp\RipBot264temp\job88"
$mkvmerge = ($RipBot264PATH + '\Tools\mkvtoolnix\mkvmerge.exe')
$mkvextract = ($RipBot264PATH + '\Tools\mkvtoolnix\mkvextract.exe')

$demuxpath = ($path + '\' + $file.BaseName + '_demux\')
$remuxpath = ($path + '\' + $file.BaseName + '_remux\')
$basename = $file.BaseName
Remove-Item -LiteralPath $demuxpath -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -LiteralPath $remuxpath -Force -Recurse -ErrorAction SilentlyContinue

New-Item -ItemType "directory" -Path $demuxpath -ErrorAction SilentlyContinue | Out-Null
New-Item -ItemType "directory" -Path $remuxpath -ErrorAction SilentlyContinue | Out-Null

#[string]$mkvSTDOUT_FILE = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([System.IO.Path]::GetRandomFileName().Split('.')[0] + ".txt")
#[string]$mkvSTDERROUT_FILE = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([System.IO.Path]::GetRandomFileName().Split('.')[0] + ".txt")
[string]$AudioExtJson = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([System.IO.Path]::GetRandomFileName().Split('.')[0] + ".json")
[string]$STDOUT_FILE = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([System.IO.Path]::GetRandomFileName().Split('.')[0] + ".txt")
[string]$STDERR_FILE = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([System.IO.Path]::GetRandomFileName().Split('.')[0] + ".txt")
$text = @"
<?xml version="1.0" encoding="utf-8"?>
<codecs>
    <codec>
        <id>A_AAC</id>
        <name>AAC</name>
        <desc>Advanced Audio Coding</desc>
        <ext>aac</ext>
    </codec>
    <codec>
        <id>A_AAC/MPEG2/MAIN</id>
        <name>AAC Main</name>
        <desc>AAC MPEG-2 Main Profile</desc>
        <ext>aac</ext>
    </codec>
    <codec>
        <id>A_AAC/MPEG2/LC</id>
        <name>AAC LC</name>
        <desc>AAC MPEG-2 Low Complexity</desc>
        <ext>aac</ext>
    </codec>
    <codec>
        <id>A_AAC/MPEG2/LC/SBR</id>
        <name>AAC LC+SBR</name>
        <desc>AAC MPEG-2 Low Complexity with SBR</desc>
        <ext>aac</ext>
    </codec>
    <codec>
        <id>A_AAC/MPEG2/SSR</id>
        <name>AAC SSR</name>
        <desc>AAC MPEG-2 Scalable Sampling Rate</desc>
        <ext>aac</ext>
    </codec>
    <codec>
        <id>A_AAC/MPEG4/MAIN</id>
        <name>AAC Main</name>
        <desc>AAC MPEG-4 Main Profile</desc>
        <ext>aac</ext>
    </codec>
    <codec>
        <id>A_AAC/MPEG4/LC</id>
        <name>AAC LC</name>
        <desc>AAC Low Complexity</desc>
        <ext>aac</ext>
    </codec>
    <codec>
        <id>A_AAC/MPEG4/LC/SBR</id>
        <name>AAC LC+SBR</name>
        <desc>AAC Low Complexity with Spectral Band Replication</desc>
        <ext>aac</ext>
    </codec>
    <codec>
        <id>A_AAC/MPEG4/SSR</id>
        <name>AAC SSR</name>
        <desc>AAC Scalable Sampling Rate</desc>
        <ext>aac</ext>
    </codec>
    <codec>
        <id>A_AAC/MPEG4/LTP</id>
        <name>AAC SSR</name>
        <desc>AAC Long Term Prediction</desc>
        <ext>aac</ext>
    </codec>
    <codec>
        <id>A_AC3</id>
        <name>AC3</name>
        <desc>Dolby Digital</desc>
        <ext>ac3</ext>
    </codec>
    <codec>
        <id>A_AC3/BSID10</id>
        <name>AC3</name>
        <desc>Dolby Digital (8-12kHz)</desc>
        <ext>ac3</ext>
    </codec>
    <codec>
        <id>A_AC3/BSID9</id>
        <name>AC3</name>
        <desc>Dolby Digital (16-24kHz)</desc>
        <ext>ac3</ext>
    </codec>
    <codec>
        <id>A_MS/ACM</id>
        <name>ACM</name>
        <desc>Microsoft Audio Codec Manager</desc>
    </codec>
    <codec>
        <id>A_ALAC</id>
        <name>ALAC</name>
        <desc>Apple Lossless Audio Codec</desc>
        <ext>alac</ext>
    </codec>
    <codec>
        <id>A_DTS</id>
        <name>DTS</name>
        <desc>Digital Theatre System (DTS/DTS-ES/DTS-HDMA/DTS-HRA)</desc>
        <ext>dts</ext>
    </codec>
    <codec>
        <id>A_DTS/EXPRESS</id>
        <name>DTS Express</name>
        <desc>Digital Theatre System (DTS Express)</desc>
        <ext>dts</ext>
    </codec>
    <codec>
        <id>A_DTS/LOSSLES</id>
        <name>DTS Lossless</name>
        <desc>Digital Theatre System (DTS Lossless)</desc>
        <ext>dts</ext>
    </codec>
    <codec>
        <id>A_EAC3</id>
        <name>E-AC3</name>
        <desc>Dolby Digital Plus</desc>
        <ext>eac3</ext>
    </codec>
    <codec>
        <id>A_FLAC</id>
        <name>FLAC</name>
        <desc>Free Lossless Audio Codec</desc>
        <ext>flac</ext>
    </codec>
    <codec>
        <id>A_MLP</id>
        <name>MLP</name>
        <desc>Meridian Lossless Packing</desc>
        <ext>mlp</ext>
    </codec>
    <codec>
        <id>A_MPC</id>
        <name>Musepack</name>
        <desc>Musepack</desc>
        <ext>mpc</ext>
    </codec>
    <codec>
        <id>A_MPEG/L1</id>
        <name>MP1</name>
        <desc>MPEG Audio 1/2 Layer I</desc>
        <ext>mp1</ext>
    </codec>
    <codec>
        <id>A_MPEG/L2</id>
        <name>MP2</name>
        <desc>MPEG Audio 1/2 Layer II</desc>
        <ext>mp2</ext>
    </codec>
    <codec>
        <id>A_MPEG/L3</id>
        <name>MP3</name>
        <desc>MPEG Audio 1/2 Layer III</desc>
        <ext>mp3</ext>
    </codec>
    <codec>
        <id>A_OPUS</id>
        <name>Opus</name>
        <desc>Opus Audio Codec</desc>
        <ext>opus</ext>
    </codec>
    <codec>
        <id>A_PCM/INT/BIG</id>
        <name>PCM BE</name>
        <desc>PCM Int, Big Endian</desc>
        <ext>pcm</ext>
    </codec>
    <codec>
        <id>A_PCM/INT/LIT</id>
        <name>PCM LE</name>
        <desc>PCM Int, Little Endian</desc>
        <ext>pcm</ext>
    </codec>
    <codec>
        <id>A_PCM/FLOAT/IEEE</id>
        <name>PCM FP</name>
        <desc>PCM Floating Point, IEEE compatible</desc>
        <ext>pcm</ext>
    </codec>
    <codec>
        <id>A_QUICKTIME</id>
        <name>Quicktime</name>
        <desc>Apple Quicktime Audio</desc>
        <ext>UNKNOWN</ext>
    </codec>
    <codec>
        <id>A_QUICKTIME/QDMC</id>
        <name>QDesign</name>
        <desc>QDesign Music</desc>
        <ext>UNKNOWN</ext>
    </codec>
    <codec>
        <id>A_QUICKTIME/QDM2</id>
        <name>QDesign</name>
        <desc>QDesign Music v2</desc>
        <ext>UNKNOWN</ext>
    </codec>

    <codec>
        <id>A_REAL/14_4</id>
        <name>RA1</name>
        <desc>RealAudio 1 (IS-54 VSELP)</desc>
        <ext>ra</ext>
    </codec>
    <codec>
        <id>A_REAL/28_8</id>
        <name>RA2</name>
        <desc>RealAudio 2 (G.728 LD-CELP)</desc>
        <ext>ra</ext>
    </codec>
    <codec>
        <id>A_REAL/ATRC</id>
        <name>ATRAC3</name>
        <desc>Sony ATRAC3 (RA8)</desc>
        <ext>ra</ext>
    </codec>
    <codec>
        <id>A_REAL/COOK</id>
        <name>Cook</name>
        <desc>RealAudio Cook Codec (RA4/5)</desc>
        <ext>ra</ext>
    </codec>
    <codec>
        <id>A_REAL/SIPR</id>
        <name>Sipro</name>
        <desc>Sipro Lab Telecom ACELP-NET Voice Codec</desc>
        <ext>ra</ext>
    </codec>
    <codec>
        <id>A_REAL/RALF</id>
        <name>Real LL</name>
        <desc>Real Audio Lossless Format</desc>
        <ext>ra</ext>
    </codec>
    <codec>
        <id>A_TTA1</id>
        <name>TTA</name>
        <desc>The True Audio lossless audio</desc>
        <ext>tta</ext>
    </codec>
    <codec>
        <id>A_TRUEHD</id>
        <name>TrueHD</name>
        <desc>Dolby TrueHD lossless audio</desc>
        <ext>thd</ext>
    </codec>
    <codec>
        <id>A_VORBIS</id>
        <name>Vorbis</name>
        <ext>ogg</ext>
    </codec>
    <codec>
        <id>A_WAVPACK4</id>
        <name>WavPack</name>
        <desc>WavPack lossless audio</desc>
        <ext>wv</ext>
    </codec>
    <codec>
        <id>V_MPEG1</id>
        <name>MPEG-1</name>
        <desc>MPEG-1 video</desc>
        <ext>mpg</ext>
    </codec>
    <codec>
        <id>V_MPEG2</id>
        <name>MPEG-2</name>
        <desc>MPEG-2 video</desc>
        <ext>mpg</ext>
    </codec>
    <codec>
        <id>V_MPEG4/ISO</id>
        <name>MPEG-4 ISO</name>
        <desc>MPEG-4 Part 2 ISO</desc>
        <ext>avi</ext>
    </codec>
    <codec>
        <id>V_MPEG4/ISO/SP</id>
        <name>MPEG-4 SP</name>
        <desc>MPEG-4 Part 2 Simple Profile</desc>
        <ext>avi</ext>
    </codec>
    <codec>
        <id>V_MPEG4/ISO/ASP</id>
        <name>MPEG-4 ASP</name>
        <desc>MPEG-4 Part 2 Advanced Simple Profile</desc>
        <ext>avi</ext>
    </codec>
    <codec>
        <id>V_MPEG4/ISO/AP</id>
        <name>MPEG-4 AP</name>
        <desc>MPEG-4 Part 2 Advanced Profile</desc>
        <ext>avi</ext>
    </codec>
    <codec>
        <id>V_MPEG4/ISO/AVC</id>
        <name>H.264/AVC</name>
        <desc>MPEG-4 Part 10 Advanced Video Coding</desc>
        <ext>h264</ext>
    </codec>
    <codec>
        <id>V_MPEGH/ISO/HEVC</id>
        <name>H.265/HEVC</name>
        <desc>MPEG-H Part 2 High Efficiency Video Coding</desc>
        <ext>hevc</ext>
    </codec>
    <codec>
        <id>V_MPEG4/MS/V3</id>
        <name>DivX3</name>
        <desc>MS MPEG-4 V3 VfW / DivX3</desc>
        <ext>avi</ext>
    </codec>
    <codec>
        <id>V_PRORES</id>
        <name>ProRes</name>
        <desc>Apple ProRes 422/444</desc>
        <ext>mov</ext>
    </codec>
    <codec>
        <id>V_THEORA</id>
        <name>Theora</name>
        <desc>Theora</desc>
        <ext>ogv</ext>
    </codec>
    <codec>
        <id>V_UNCOMPRESSED</id>
        <name>RAW</name>
        <desc>Uncompressed video</desc>
        <ext>UNKNOWN</ext>
    </codec>
    <codec>
        <id>V_MS/VFW/FOURCC</id>
        <name>VFW</name>
        <desc>Microsoft Video Codec Manager / Video for Windows</desc>
        <ext>avi</ext>
    </codec>
    <codec>
        <id>S_TEXT/ASS</id>
        <name>ASS</name>
        <desc>Advanced SubStation (SSA v4+)</desc>
        <ext>ass</ext>
    </codec>
    <codec>
        <id>S_TEXT/SSA</id>
        <name>ASS</name>
        <desc>SubStation Alpha v4</desc>
        <ext>ssa</ext>
    </codec>
    <codec>
        <id>S_TEXT/UTF8</id>
        <name>SRT</name>
        <desc>SubRip Text (UTF-8)</desc>
        <ext>srt</ext>
    </codec>
    <codec>
        <id>S_TEXT/USF</id>
        <name>USF</name>
        <desc>Universal Subtitle Format</desc>
        <ext>usf</ext>
    </codec>
    <codec>
        <id>S_IMAGE/BMP</id>
        <name>Bitmap</name>
        <desc>Basic Image subtitles</desc>
        <ext>bmp</ext>
    </codec>
    <codec>
        <id>S_VOBSUB</id>
        <name>VobSub</name>
        <desc>VobSub DVD Image subtitles</desc>
        <ext>sub</ext>
    </codec>
    <codec>
        <id>S_HDMV/PGS</id>
        <name>PGS</name>
        <desc>Presentation Graphic Stream Subtitle Format</desc>
        <ext>sup</ext>
    </codec>
    <codec>
        <id>S_KATE</id>
        <name>Kate</name>
        <desc>Karaoke And Text Encapsulation</desc>
        <ext>kate</ext>
    </codec>
</codecs>
"@
##########################################################################



function _CreateVideoIndexFile {
    #CreateVideoIndexFile.avs
    Add-Content -Path ($temppath + "\CreateVideoIndexFile.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\lsmash\LSMASHSource.dll")')
    Add-Content -Path ($temppath + "\CreateVideoIndexFile.avs") -Value ('LWLibavVideoSource("' + $File + '",cachefile="' + $temppath + '\' + $File.basename + $file.Extension + '.lwi")')
    Add-Content -Path ($temppath + "\CreateVideoIndexFile.avs") -Value ('Trim(0,-1)')
}

function _getinfo {
    #generate getinfo.avs
    Add-Content -Path ($temppath + "\getinfo.avs") -Value ('#MT') 
    Add-Content -Path ($temppath + "\getinfo.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\lsmash\LSMASHSource.dll")')
    Add-Content -Path ($temppath + "\getinfo.avs") -Value ('video=LWLibavVideoSource("' + $file + '",cachefile="' + $temppath + '\' + $File.basename + $file.Extension + '.lwi")')
    Add-Content -Path ($temppath + "\getinfo.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\Plugins_JPSDR\Plugins_JPSDR.dll")')
    Add-Content -Path ($temppath + "\getinfo.avs") -Value ('video=Spline64ResizeMT(video,1280,720)')
    Add-Content -Path ($temppath + "\getinfo.avs") -Value ('video=WriteFile(video,"' + $temppath + '\info.txt","Framecount")')
    Add-Content -Path ($temppath + "\getinfo.avs") -Value ('video=WriteFile(video,"' + $temppath + '\info.txt","Framerate")')
    Add-Content -Path ($temppath + "\getinfo.avs") -Value ('video=WriteFile(video,"' + $temppath + '\info.txt","AudioRate")')
    Add-Content -Path ($temppath + "\getinfo.avs") -Value ('video=WriteFile(video,"' + $temppath + '\info.txt","AudioChannels")')
    Add-Content -Path ($temppath + "\getinfo.avs") -Value ('video=WriteFile(video,"' + $temppath + '\info.txt","AudioLength")')
    Add-Content -Path ($temppath + "\getinfo.avs") -Value ('video=WriteFile(video,"' + $temppath + '\info.txt","Width")') 
    Add-Content -Path ($temppath + "\getinfo.avs") -Value ('video=WriteFile(video,"' + $temppath + '\info.txt","Height")') 
    Add-Content -Path ($temppath + "\getinfo.avs") -Value ('video=WriteFile(video,"' + $temppath + '\info.txt","PixelType")')
    Add-Content -Path ($temppath + "\getinfo.avs") -Value ('Trim(video,0,-1)') 
}

function _job88_EncodingClient($file) {
    $video = (&$mediainfo --Output=JSON --full "$file") | ConvertFrom-Json
    [string]$thisfps = $video.media.track.FrameRate[0]
    [String]$global:ratio = $video.media.track.DisplayAspectRatio_String
    [String]$global:defaultduration = $video.media.track.FrameRate[0]
    #Generate EncodingClient.meta
    Add-Content -Path ($temppath + "\job88_EncodingClient.meta") -Value ($temppath)
    Add-Content -Path ($temppath + "\job88_EncodingClient.meta") -Value ($RipBot264PATH)
    Add-Content -Path ($temppath + "\job88_EncodingClient.meta") -Value ('"' + $RipBot264PATH + '\Tools\ffmpeg\bin\ffmpeg.exe" -loglevel panic -i "' + $temppath + '\job88.avs" -strict -1 -f yuv4mpegpipe - | "' + $RipBot264PATH + '\tools\x264\x264_x64.exe" --colorprim bt709 --transfer bt709 --colormatrix bt709  --crf ' + $crf + ' --fps ' + $thisfps + ' --force-cfr --min-keyint 24 --keyint 240 --frames ' + $fps + ' --sar 1:1 '+ $myprofile + $level + $tune + $preset + '--stdin y4m --output "' + $temppath + '\video.264" -')
    Add-Content -Path ($temppath + "\job88_EncodingClient.meta") -Value ('') 
    Add-Content -Path ($temppath + "\job88_EncodingClient.meta") -Value ($File.FullName)
    Add-Content -Path ($temppath + "\job88_EncodingClient.meta") -Value ('h264') 
    Add-Content -Path ($temppath + "\job88_EncodingClient.meta") -Value ('1')
}

function _job88 {
    #generate job88.avs
    Add-Content -Path ($temppath + "\job88.avs") -Value ('#MT')
    Add-Content -Path ($temppath + "\job88.avs") -Value ('')
    Add-Content -Path ($temppath + "\job88.avs") -Value ('#VideoSource')
    Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\lsmash\LSMASHSource.dll")')
    Add-Content -Path ($temppath + "\job88.avs") -Value ('video=LWLibavVideoSource("' + $file + '",cachefile="' + $temppath + '\' + $File.basename + $file.Extension + '.lwi")')
    Add-Content -Path ($temppath + "\job88.avs") -Value ('')
    #Deinterlace
    Add-Content -Path ($temppath + "\job88.avs") -Value ('#Deinterlace')
    if ($dBFF2x -eq $true) {
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\RgTools\RgTools.dll")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\nnedi3\nnedi3.dll")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\masktools\masktools2.dll")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\mvtools\mvtools2.dll")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadCPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\Yadif\Yadif.dll")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('Import("' + $RipBot264PATH + '\Tools\AviSynth plugins\Scripts\QTGMC.avs")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('video=AssumeBFF(video).QTGMC(Preset="Medium",FPSDivisor=1)')
    }
    if ($dBFF1x -eq $true) {
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\RgTools\RgTools.dll")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\nnedi3\nnedi3.dll")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\masktools\masktools2.dll")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\mvtools\mvtools2.dll")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadCPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\Yadif\Yadif.dll")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('Import("' + $RipBot264PATH + '\Tools\AviSynth plugins\Scripts\QTGMC.avs")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('video=AssumeBFF(video).QTGMC(Preset="Medium",FPSDivisor=2)')
    }
    if ($dTFF2x -eq $true) {
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\RgTools\RgTools.dll")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\nnedi3\nnedi3.dll")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\masktools\masktools2.dll")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\mvtools\mvtools2.dll")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadCPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\Yadif\Yadif.dll")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('Import("' + $RipBot264PATH + '\Tools\AviSynth plugins\Scripts\QTGMC.avs")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('video=AssumeTFF(video).QTGMC(Preset="Medium",FPSDivisor=1)')
    }
    if ($dTFF1x -eq $true) {
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\RgTools\RgTools.dll")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\nnedi3\nnedi3.dll")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\masktools\masktools2.dll")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\mvtools\mvtools2.dll")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadCPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\Yadif\Yadif.dll")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('Import("' + $RipBot264PATH + '\Tools\AviSynth plugins\Scripts\QTGMC.avs")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('video=AssumeTFF(video).QTGMC(Preset="Medium",FPSDivisor=2)')
    }
    if ($IT -eq $true) {
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\TIVTC\TIVTC.dll")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('video=tfm(video,order=1)')
    }
    Add-Content -Path ($temppath + "\job88.avs") -Value ('')
    #Decimate
    Add-Content -Path ($temppath + "\job88.avs") -Value ('#Decimate')
    if ($IT -eq $true) {
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\TIVTC\TIVTC.dll")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('video=TDecimate(video)')
    }
    if ($Decimate-eq $true) {
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\TIVTC\TIVTC.dll")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('video=TDecimate(video)')
    }
    Add-Content -Path ($temppath + "\job88.avs") -Value ('')
    #Crop
    Add-Content -Path ($temppath + "\job88.avs") -Value ('#Crop')
    if (Test-Path -LiteralPath $file.FullName.Replace($file.Extension , '.crop')) {
        $cropit = Get-Content $file.FullName.Replace($file.Extension , '.crop') -First 1
        $regex = [regex]"\((.*)\)"
        $cropit = [regex]::match($cropit, $regex).Groups[1]
        $cropit = $cropit.Value
        Add-Content -Path ($temppath + "\job88.avs") -Value (('video=Crop(video,' + $cropit + ')'))
        Remove-Item -LiteralPath ($file.FullName.Replace($file.Extension , '.crop')) -Force -Recurse -ErrorAction SilentlyContinue
    } else {
        Add-Content -Path ($temppath + "\job88.avs") -Value ('')    
    }
    if ($crop -ne $false) {
        $cropBreakdown = $crop.Split(",")
        if ($cropBreakdown.Length -ne 4) {
            Write-Output "improper use of -crop"
            Exit
        }
        Add-Content -Path ($temppath + "\job88.avs") -Value ("video=Crop(video,$cropBreakdown[0],$cropBreakdown[1],-$cropBreakdown[2],-$cropBreakdown[3])")
    } else {
        Add-Content -Path ($temppath + "\job88.avs") -Value ('')
    }
    #Resize
     Add-Content -Path ($temppath + "\job88.avs") -Value ('#Resize')
    if ($s2160-eq $true) {
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\Plugins_JPSDR\Plugins_JPSDR.dll")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('video=Spline64ResizeMT(video,3840,2160)')
    }
    if ($s1080 -eq $true) {
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\Plugins_JPSDR\Plugins_JPSDR.dll")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('video=Spline64ResizeMT(video,1920,1080)')
    }
    if ($s720 -eq $true) {
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\Plugins_JPSDR\Plugins_JPSDR.dll")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('video=Spline64ResizeMT(video,1280,720)')
    }
    if ($s576 -eq $true) {
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\Plugins_JPSDR\Plugins_JPSDR.dll")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('video=Spline64ResizeMT(video,720,576)')
    }
    if ($s480 -eq $true) {
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\Plugins_JPSDR\Plugins_JPSDR.dll")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('video=Spline64ResizeMT(video,720,480)')
    }
    Add-Content -Path ($temppath + "\job88.avs") -Value ('')
    #Tonemap
    Add-Content -Path ($temppath + "\job88.avs") -Value ('#Tonemap')
    if ($Tonemap -eq $true) {
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\HDRTools\hdrtools.dll")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('Import("' + $RipBot264PATH + '\Tools\AviSynth plugins\Scripts\HDRtoSDR.avs")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('video=HDRtoSDR(video,"PQ")')
    }
    Add-Content -Path ($temppath + "\job88.avs") -Value ('')
    #Levels
    Add-Content -Path ($temppath + "\job88.avs") -Value ('#Levels')
    if ($LPC -eq $true) {
        Add-Content -Path ($temppath + "\job88.avs") -Value ('video=Levels(video,16, 1, 235, 0, 255, coring=false)')
    } else {
        Add-Content -Path ($temppath + "\job88.avs") -Value ('')
    }
    if ($LTV -eq $true) {
        Add-Content -Path ($temppath + "\job88.avs") -Value ('video=Levels(video,0, 1, 255, 16, 235, coring=false)')
    } else {
        Add-Content -Path ($temppath + "\job88.avs") -Value ('')
    }
    #Colours
    Add-Content -Path ($temppath + "\job88.avs") -Value ('#Colours')
    if ($colors -ne $false) {
        $colorsBreakdown = $colors.Split(",")
        if ($colorsBreakdown.Length -ne 4) {
            Write-Output "improper use of -colors"
            Exit
        }
        if ($colorsBreakdown[0] -as [int] -gt 180) { $colorsBreakdown[0] = "180"}
        if ($colorsBreakdown[0] -as [int] -lt -180) { $colorsBreakdown[0] = "-180"}
    
        if ($colorsBreakdown[1] -as [int] -gt 2) { $colorsBreakdown[1] = "2"}
        if ($colorsBreakdown[1] -as [int] -lt 0) { $colorsBreakdown[1] = "0"}
    
        if ($colorsBreakdown[2] -as [int] -gt 255) { $colorsBreakdown[2] = "255"}
        if ($colorsBreakdown[2] -as [int] -lt -255) { $colorsBreakdown[2] = "-255"}
    
        if ($colorsBreakdown[3] -as [int] -gt 2) { $colorsBreakdown[3] = "2"}
        if ($colorsBreakdown[3] -as [int] -lt 0) { $colorsBreakdown[3] = "0"}
        Add-Content -Path ($temppath + "\job88.avs") -Value ("video=Tweak(video,hue=$colorsBreakdown[0],sat=$colorsBreakdown[1],bright=$colorsBreakdown[2],cont=$colorsBreakdown[3]")
    } else {
        Add-Content -Path ($temppath + "\job88.avs") -Value ('')
    }
    #Denoise
    Add-Content -Path ($temppath + "\job88.avs") -Value ('#Denoise')
    if ($mdegrain1 -eq $true) {
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\mvtools\mvtools2.dll")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('super=MSuper(video,pel=2)')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('fv1=MAnalyse(super,isb=false,delta=1,overlap=4)')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('bv1=MAnalyse(super,isb=true,delta=1,overlap=4)')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('video=MDegrain1(video,super,bv1,fv1,thSAD=' + $mdegrain1 + ')')
    }
    if ($mdegrain2 -eq $true) {
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\mvtools\mvtools2.dll")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('super=MSuper(video,pel=2)')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('fv1=MAnalyse(super,isb=false,delta=1,overlap=4)')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('bv1=MAnalyse(super,isb=true,delta=1,overlap=4)')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('fv2=MAnalyse(super,isb=false,delta=2,overlap=4)')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('bv2=MAnalyse(super,isb=true,delta=2,overlap=4)')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('video=MDegrain2(video,super,bv1,fv1,bv2,fv2,thSAD=' + $mdegrain1 + ')')
    }
    if ($mdegrain3 -eq $true) {
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\mvtools\mvtools2.dll")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('super=MSuper(video,pel=2)')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('fv1=MAnalyse(super,isb=false,delta=1,overlap=4)')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('bv1=MAnalyse(super,isb=true,delta=1,overlap=4)')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('fv2=MAnalyse(super,isb=false,delta=2,overlap=4)')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('bv2=MAnalyse(super,isb=true,delta=2,overlap=4)')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('fv3=MAnalyse(super,isb=false,delta=3,overlap=4)')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('bv3=MAnalyse(super,isb=true,delta=3,overlap=4)')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('video=MDegrain3(video,super,bv1,fv1,bv2,fv2,bv3,fv3,thSAD=' + $mdegrain1 + ')')
    }
    Add-Content -Path ($temppath + "\job88.avs") -Value ('')
    #Custom
    Add-Content -Path ($temppath + "\job88.avs") -Value ('#Custom')
    if ($addborders -eq $true) {
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\Scripts\AutoBorders.avs")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('video=AutoBorders(video,16.0/9.0)')
    }
    Add-Content -Path ($temppath + "\job88.avs") -Value ('')
    #Prefetch
    Add-Content -Path ($temppath + "\job88.avs") -Value ('#Prefetch')
    Add-Content -Path ($temppath + "\job88.avs") -Value ('')
    #After_Prefetch_Denoise
    Add-Content -Path ($temppath + "\job88.avs") -Value ('#After_Prefetch_Denoise')
    Add-Content -Path ($temppath + "\job88.avs") -Value ('')
    #After_Prefetch_Custom
    Add-Content -Path ($temppath + "\job88.avs") -Value ('#After_Prefetch_Custom')
    if ($interlace -eq $true) {
        Add-Content -Path ($temppath + "\job88.avs") -Value ('video=AssumeFrameBased(video).AssumeTFF.SeparateFields.SelectEvery(4, 0, 3).Weave')
    }
    Add-Content -Path ($temppath + "\job88.avs") -Value ('')
    #Sharpen
    Add-Content -Path ($temppath + "\job88.avs") -Value ('#Sharpen')
    if ($sh25-eq $true) {
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\Plugins_JPSDR\Plugins_JPSDR.dll")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\CAS\CAS.dll")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('Import("' + $RipBot264PATH + '\Tools\AviSynth plugins\Scripts\MCAS.avs")')    Add-Content -Path ($temppath + "\job88.avs") -Value ('#Sharpen')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('video=MCAS(video,0.25)')
    }
    if ($sh50-eq $true) {
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\Plugins_JPSDR\Plugins_JPSDR.dll")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\CAS\CAS.dll")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('Import("' + $RipBot264PATH + '\Tools\AviSynth plugins\Scripts\MCAS.avs")')    Add-Content -Path ($temppath + "\job88.avs") -Value ('#Sharpen')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('video=MCAS(video,0.50)')
    } 
    if ($sh75-eq $true) {
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\Plugins_JPSDR\Plugins_JPSDR.dll")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\CAS\CAS.dll")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('Import("' + $RipBot264PATH + '\Tools\AviSynth plugins\Scripts\MCAS.avs")')    Add-Content -Path ($temppath + "\job88.avs") -Value ('#Sharpen')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('video=MCAS(video,0.75)')
    } 
    if ($sh100-eq $true) {
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\Plugins_JPSDR\Plugins_JPSDR.dll")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\CAS\CAS.dll")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('Import("' + $RipBot264PATH + '\Tools\AviSynth plugins\Scripts\MCAS.avs")')    Add-Content -Path ($temppath + "\job88.avs") -Value ('#Sharpen')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('video=MCAS(video,1.0)')
    }   
    Add-Content -Path ($temppath + "\job88.avs") -Value ('')
    #Borders
    Add-Content -Path ($temppath + "\job88.avs") -Value ('#Borders')
    if ($s2160-eq $true) {
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\Scripts\AutoBorders.avs")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('video=AutoBorders(video,16.0/9.0)')
    }
    if ($s1080 -eq $true) {
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\Scripts\AutoBorders.avs")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('video=AutoBorders(video,16.0/9.0)')
    }
    if ($s720 -eq $true) {
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\Scripts\AutoBorders.avs")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('video=AutoBorders(video,16.0/9.0)')
    }
    if ($s576 -eq $true) {
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\Scripts\AutoBorders.avs")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('video=AutoBorders(video,1.25)')
    }
    if ($s480 -eq $true) {
        Add-Content -Path ($temppath + "\job88.avs") -Value ('LoadPlugin("' + $RipBot264PATH + '\Tools\AviSynth plugins\Scripts\AutoBorders.avs")')
        Add-Content -Path ($temppath + "\job88.avs") -Value ('video=AutoBorders(video,1.5)')
    }
    Add-Content -Path ($temppath + "\job88.avs") -Value ('')
    #Subtitles
    Add-Content -Path ($temppath + "\job88.avs") -Value ('#Subtitles')
    Add-Content -Path ($temppath + "\job88.avs") -Value ('')
    #AudioSource
    Add-Content -Path ($temppath + "\job88.avs") -Value ('#AudioSource')
    Add-Content -Path ($temppath + "\job88.avs") -Value ('')
    #Triming
    Add-Content -Path ($temppath + "\job88.avs") -Value ('#Triming')
    Add-Content -Path ($temppath + "\job88.avs") -Value ('')
    #AVSameLength
    Add-Content -Path ($temppath + "\job88.avs") -Value ('#AVSameLength')
    Add-Content -Path ($temppath + "\job88.avs") -Value ('')
    #ColorSpace
    Add-Content -Path ($temppath + "\job88.avs") -Value ('#ColorSpace')
    Add-Content -Path ($temppath + "\job88.avs") -Value ('')
    #Return
    Add-Content -Path ($temppath + "\job88.avs") -Value ('#Return')
    Add-Content -Path ($temppath + "\job88.avs") -Value ('return video') 
 }

 function _DeMuxAll($file) {
    $file = Get-Childitem -LiteralPath $file -ErrorAction Stop
    $Global:framerate = &$ffprobe -i $file -v error -select_streams v -of default=noprint_wrappers=1:nokey=1 -show_entries stream=r_frame_rate
    #get --identify from mkvmerge for all tracks
    $videoMKVinfo = &$mkvmerge --ui-language en --identify  --identification-format json "$file" | ConvertFrom-Json
    $ChapCheck = $videoMKVinfo.chapters.count -gt 0
    $videoMKVinfo = $videoMKVinfo.tracks

    #load Xml that gets extension for a codecID
    $codecIDs = [xml]$text | ForEach-Object { $_.codecs.codec }

    $NumberOfTracks = $videoMKVinfo.count

    #1st character of codec_id identifies the type of track (($videoMKVinfo | Where-Object id -eq 0).properties.codec_id).Substring(0,1) V=video A=audio S=subtitle

    $commandline = '"' + $file + '"  tracks --ui-language en  '

    for ($i = 0; $i -lt $NumberOfTracks; $i++) {
        $lang = ($videoMKVinfo | Where-Object id -eq $i).properties.language
        if ((($videoMKVinfo | Where-Object id -eq $i).properties.codec_id).Substring(0, 1) -eq 'A') {
            $delay = (($videoMKVinfo | Where-Object id -eq $i).properties.minimum_timestamp) / 1000000
            if ($SkipA -eq 'True') {
                $commandline = $commandline
            } else {
                $commandline = $commandline + $i + ':"' + $demuxpath + $file.BaseName + '_track' + $i + '_[' + $lang + ']' + '_DELAY ' + $delay + 'ms.' + ($codecIDs | Where-Object { $_.id -eq (($videoMKVinfo | Where-Object id -eq $i).properties.codec_id) }).ext + '" '
            }
        }
        if ((($videoMKVinfo | Where-Object id -eq $i).properties.codec_id).Substring(0, 1) -eq 'S') {
            if ($SkipS -eq 'True') {
                $commandline = $commandline
            } else {
                $commandline = $commandline + $i + ':"' + $demuxpath + $file.BaseName + '_track' + $i + '_[' + $lang + ']' + '.' + ($codecIDs | Where-Object { $_.id -eq (($videoMKVinfo | Where-Object id -eq $i).properties.codec_id) }).ext + '" '
            }
        }
    }

    Start-Process -FilePath $mkvextract -ArgumentList $commandline -wait -NoNewWindow #-RedirectStandardError nul

   if ($ChapCheck -eq 'True') {
        #New-Item -ItemType "directory" -Path ((Get-Location).path + '\chapters') -ErrorAction SilentlyContinue | Out-Null
        Start-Process -FilePath $mkvextract -ArgumentList ('"' + $file + '" chapters --ui-language en --simple "' + $remuxpath + $file.BaseName + '_chapters.txt"') -wait -NoNewWindow #-RedirectStandardError nul
   }

}

function _WrapAudio($file) {
    $file = Get-ChildItem -LiteralPath $file
    $json = ''
    $json = "--ui-language", "en", "--output"
    $json = $json += $file.FullName.Replace($file.Extension , '.mkv')
    $json = $json += "--language","0:und","("
    $json = $json += $file.FullName
    $json = $json += ")"
    $json | ConvertTo-Json -depth 100 | Out-File "$AudioExtJson"
    Start-Process -FilePath $mkvmerge -ArgumentList ('"' + "@$AudioExtJson" + '"') -wait -NoNewWindow #-RedirectStandardError nul
    $global:mkvfile = $file.FullName.Replace($file.Extension , '.mkv')
    $global:mkvfile = Get-ChildItem -LiteralPath $mkvfile
}

function _Normalize($File,$bitrate,$freq,$codec,$audioext) {

$file = Get-Childitem -LiteralPath $file -ErrorAction Stop    
$remuxpath = $file.fullname.replace(($file.name),"").replace("_demux","_remux")
$mkvfile = $file

[string]$STDOUT_FILE = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([System.IO.Path]::GetRandomFileName().Split('.')[0] + ".txt")
[string]$STDERR_FILE = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([System.IO.Path]::GetRandomFileName().Split('.')[0] + ".txt")

[string]$OutputFileExt = "." + $audioext
$file = Get-Childitem -LiteralPath $mkvfile -ErrorAction Stop

$Source_Path = $file
$PASS2_FILE = ($remuxpath + $file.name.Replace($file.Extension, $OutputFileExt))

Write-Output "Starting part 1 of 2 for normalization"
$ArgumentList = '-progress - -nostats -nostdin -y -i "' + $file + '" -af loudnorm=i=-23.0:lra=7.0:tp=-2.0:offset=0.0:print_format=json -hide_banner -f null -'

$ffmpeg_do = Start-Process $ffmpeg -ArgumentList $ArgumentList -RedirectStandardError $STDERR_FILE -RedirectStandardOutput $STDOUT_FILE -Wait -NoNewWindow

$input_i = (((Get-Content -LiteralPath $STDERR_FILE | Where-Object { $_ -Like '*input_i*' }).Split(" "))[2]).Replace('"', "").Replace(',', "")
$input_tp = (((Get-Content -LiteralPath $STDERR_FILE | Where-Object { $_ -Like '*input_tp*' }).Split(" "))[2]).Replace('"', "").Replace(',', "")
$input_lra = (((Get-Content -LiteralPath $STDERR_FILE | Where-Object { $_ -Like '*input_lra*' }).Split(" "))[2]).Replace('"', "").Replace(',', "")
$input_thresh = (((Get-Content -LiteralPath $STDERR_FILE | Where-Object { $_ -Like '*input_thresh*' }).Split(" "))[2]).Replace('"', "").Replace(',', "")
$target_offset = (((Get-Content -LiteralPath $STDERR_FILE | Where-Object { $_ -Like '*target_offset*' }).Split(" "))[2]).Replace('"', "").Replace(',', "")

$ArgumentList = ('-progress - -nostats -nostdin -y -i "' + $Source_Path + '" -threads 0 -hide_banner -filter_complex "[0:0]loudnorm=I=-23:TP=-2.0:LRA=7:measured_I=' + $input_i + ':measured_LRA=' + $input_lra + ':measured_TP=' + $input_tp + ':measured_thresh=' + $input_thresh + ':offset=' + $target_offset + ':linear=true:print_format=json[norm0]" -map_metadata 0 -map_metadata:s:a:0 0:s:a:0 -map_chapters 0 -c:v copy -map [norm0] -c:a ' + $codec + ' -b:a ' + $bitrate + ' -ar ' + $freq +' -c:s copy -ac 2 "' + $PASS2_FILE + '"')

Write-Output "Starting part 2 of 2 for normalization"

$ffmpeg_do = Start-Process $ffmpeg -ArgumentList $ArgumentList -Wait -NoNewWindow -RedirectStandardError $STDERR_FILE -RedirectStandardOutput $STDOUT_FILE

Remove-Item -Path $mkvfile

Write-Output "Ending part 2 of 2 for normalization"

}

Function Export-Function {
    <#
    .Synopsis
       Exports a function from a module into a user given path
    
    .Description
       As synopsis
    
    .PARAMETER Function
       This Parameter takes a String input and is used in Both Parameter Sets
    
    .PARAMETER ResolvedFunction
       This should be passed the Function that you want to work with as an object making use of the following
       $ResolvedFunction = Get-Command "Command"
    
    .PARAMETER OutPath
       This is the location that you want to output all the module files to. It is recommended not to use the same location as where the module is installed.
       Also always check the files output what you expect them to.
    
    .PARAMETER PrivateFunction
       This is a switch that is used to correctly export Private Functions and is used internally in Export-AllModuleFunction
    
    .EXAMPLE
        Export-Function -Function Get-TwitterTweet -OutPath C:\TextFile\
    
        This will export the function into the C:\TextFile\Get\Get-TwitterTweet.ps1 file and also create a basic test file C:\TextFile\Get\Get-TwitterTweet.Tests.ps1
    
    .EXAMPLE
        Get-Command -Module SPCSPS | Where-Object {$_.CommandType -eq 'Function'} | ForEach-Object { Export-Function -Function $_.Name -OutPath C:\TextFile\SPCSPS\ }
    
        This will get all the Functions in the SPCSPS module (if it is loaded into memory or in a $env:PSModulePath as required by ModuleAutoLoading) and will export all the Functions into the C:\TextFile\SPCSPS\ folder under the respective Function Verbs. It will also create a basic Tests.ps1 file just like the prior example
    #>
    [cmdletbinding(DefaultParameterSetName='Basic')]
    
    Param(
        [Parameter(Mandatory=$true,ParameterSetName='Basic',ValueFromPipelineByPropertyName,ValueFromPipeline)]
        [Parameter(Mandatory=$true,ParameterSetName='Passthru',ValueFromPipelineByPropertyName,ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [ValidateNotNull()]
        [Alias('Command')]
        [Alias('Name')]
        [String]
        $Function,
    
        [Parameter(Mandatory=$true,ParametersetName='Passthru')]
        $ResolvedFunction,
    
        [Parameter(Mandatory=$true,ParameterSetName='Basic')]
        [Parameter(Mandatory=$true,ParameterSetName='Passthru')]
        [Alias('Path')]
        [String]
        $OutPath,
    
        [Parameter(Mandatory=$false,ParametersetName='Passthru')]
        [Alias('Private')]
        [Switch]
        $PrivateFunction
    
        )
    
    $sb = New-Object -TypeName System.Text.StringBuilder
    
     If (!($ResolvedFunction)) { $ResolvedFunction = Get-Command $function}
         $code = $ResolvedFunction | Select-Object -ExpandProperty Definition
         $PublicOutPath = "$OutPath\"
         $ps1 = "$PublicOutPath$($ResolvedFunction.Verb)\$($ResolvedFunction.Name).ps1"
    
            foreach ($line in ($code -split '\r?\n')) {
                $sb.AppendLine('{0}' -f $line) | Out-Null
            }
    
            New-Item $ps1 -ItemType File -Force | Out-Null
            Write-Verbose -Message "Created File $ps1"

            Set-Content -Path $ps1 -Value $($sb.ToString())  -Encoding UTF8
            Write-Verbose -Message "Added the content of function $Function into the file"
    
}

function _remux {
		

        #$fps = ($framerate + 'p')
        if ($defaultduration -eq "23.976") {$defaultduration = "24000/1001p"}
        if ($defaultduration -eq "29.970") {$defaultduration = "30000/1001p"}
        if ($defaultduration -eq "50.000") {$defaultduration = "50p"}
        if ($defaultduration -eq "25.000") {$defaultduration = "25p"}
        if ($defaultduration -eq "24.000") {$defaultduration = "24p"}

        $MyPath = $path

        
        $VideoList = Get-ChildItem -LiteralPath ($temppath + '\video.264') -ErrorAction SilentlyContinue -Force | Sort-Object
        foreach ($file in $VideoList) {
            $file | add-member -NotePropertyName CoreName -NotePropertyValue ($basename)
            if ($file.name -match '(\[(?<Lang>.*)\])') {$file | add-member -NotePropertyName Lang -NotePropertyValue ($Matches.Lang)} else {$file | add-member -NotePropertyName Lang -NotePropertyValue und}
            if ($file.name -match '(_DELAY (?<DELAY>.*)ms\.)') {$file | add-member -NotePropertyName Delay -NotePropertyValue ($Matches.DELAY)} else {$file | add-member -NotePropertyName Delay -NotePropertyValue 0}
        }
        
        $AudioList = Get-ChildItem -LiteralPath ($remuxpath) -Include ("*.aac", "*.ac3", "*.dts", "*.eac3", "*.flac,", "*.mp1", "*.mp2", "*.mp3", "*.ogg") -ErrorAction SilentlyContinue -Force | Sort-Object
        foreach ($file in $AudioList) {
            $file | add-member -NotePropertyName CoreName -NotePropertyValue (($file.Name.Split("_track")[0]).Split($file.Extension)[0])
            if ($file.name -match '(\[(?<Lang>.*)\])') {$file | add-member -NotePropertyName Lang -NotePropertyValue ($Matches.Lang)} else {$file | add-member -NotePropertyName Lang -NotePropertyValue und}
            if ($file.name -match '(_DELAY (?<DELAY>.*)ms\.)') {$file | add-member -NotePropertyName Delay -NotePropertyValue ($Matches.DELAY)} else {$file | add-member -NotePropertyName Delay -NotePropertyValue 0}
        }
        
        
        $SubtitleList = Get-ChildItem -LiteralPath ($remuxpath) -Include ("*.srt") -ErrorAction SilentlyContinue -Force | Sort-Object
        foreach ($file in $SubtitleList) {
            $file | add-member -NotePropertyName CoreName -NotePropertyValue (($file.Name.Split("_track")[0]).Split($file.Extension)[0])
            if ($file.name -match '(\[(?<Lang>.*)\])') {$file | add-member -NotePropertyName Lang -NotePropertyValue ($Matches.Lang)} else {$file | add-member -NotePropertyName Lang -NotePropertyValue und}
            if ($file.name -match '(_DELAY (?<DELAY>.*)ms\.)') {$file | add-member -NotePropertyName Delay -NotePropertyValue ($Matches.DELAY)} else {$file | add-member -NotePropertyName Delay -NotePropertyValue 0}
        }
        
        
        $Chapterlist = Get-ChildItem -LiteralPath ($remuxpath) -Include ("*.txt") -ErrorAction SilentlyContinue -Force | Sort-Object
        foreach ($file in $Chapterlist) {
            $file | add-member -NotePropertyName CoreName -NotePropertyValue (($file.Name.Split("_chapters")[0]).Split($file.Extension)[0])
        }
        
        foreach ($file in $VideoList) {
            $ExtJson = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([System.IO.Path]::GetRandomFileName().Split('.')[0] + ".json")
            $epAudio = $AudioList | Where-Object { $_.CoreName -eq ($file.CoreName) }    
            $epSubtitles = $SubtitleList | Where-Object { $_.CoreName -eq ($file.CoreName) }
            $epChapter = $ChapterList | Where-Object { $_.CoreName -eq ($file.CoreName) }
            
            if (Test-Path -LiteralPath ($MyPath + "\" + $file.CoreName + ".mkv")) {
                $4rand = -join ((48..57) + (97..122) | Get-Random -Count 4 | ForEach-Object {[char]$_}) #random string
                $NewName = $MyPath + "\" + $file.CoreName + "_" + $4rand + ".mkv"
            } else {
                $NewName = $MyPath + "\" + $file.CoreName + ".mkv"
            }
        
        
        #output
            $json = ''
            $json = "--ui-language", "en", "--output"
            $json = $json += $NewName
        #aspect-ratio
            $json = $json += "--language", "0:und", "--aspect-ratio" , ("0:" + $ratio.replace(':','/').trim())
        #video    
            $json = $json += "--language", "0:$($file.lang)", "--default-duration", "0:$defaultduration", "(", $($file.FullName) , ")"
        #audio
            foreach ($item in $epAudio) {
                $json = $json += "--language", "0:$($item.Lang)", "--sync", "0:$($item.Delay)", "(", $item.FullName, ")"
            }
        #Subtitle 
            foreach ($item in $epSubtitles) {
                $json = $json += "--language", "0:$($item.Lang)", "(", $item.FullName, ")"
            }
        #Chapter
            if ($epChapter) {
                $json = $json += "--chapter-language", "und", "--chapters", $epChapter[0].FullName
            }
        #footer  
            $trackcount = 1 + $epAudio.count + $epSubtitles.count
            $tracks = ''
            for ($X = 2; $X -lt $trackcount; $X++) {
                $tracks = $tracks + "," + $X + ":0"
            }
            $json = $json += "--track-order", "0:0,1:0$tracks"
            #"$($MyPath)\$($file.corename).json"
            $json | ConvertTo-Json -depth 100 | Out-File -LiteralPath $ExtJson
            Start-Process -FilePath $mkvmerge -ArgumentList ('"' + "@$($ExtJson)" + '"') -wait -NoNewWindow #-RedirectStandardError nul
            Remove-Item -LiteralPath $ExtJson
        }
        ################need to add basename to a add-member -NotePropertyName Lang -NotePropertyValue und}    
}

function _DetectBorders($file) {
    (Start-Process $detectcrop -ArgumentList ('--ffmpeg-path="' + $ffmpeg + '" --input-file="' + $file + '" --log-file="' + $file.FullName.Replace($file.Extension , '.crop"')) -Wait)
}

_DeMuxAll($file)
Remove-Item -LiteralPath $temppath -Force -Recurse -ErrorAction SilentlyContinue
New-Item -ItemType "directory" -Path $temppath -ErrorAction SilentlyContinue | Out-Null

Read-Host -Prompt "After _demux"

_CreateVideoIndexFile
Start-Process -FilePath $ffprobe -ArgumentList ('-i "' + $temppath + '\CreateVideoIndexFile.avs"') -wait -NoNewWindow

Read-Host -Prompt "After _CreateVideoIndexFile"

_getinfo
Start-Process -FilePath $ffprobe -ArgumentList ('-i "' + $temppath + '\getinfo.avs"') -wait -NoNewWindow

Read-Host -Prompt "After _getinfo"

$fps = Get-Content ($temppath + "\info.txt") -First 1
_job88_EncodingClient $File
Read-Host -Prompt "After _job88_EncodingClient"

if ($autocrop -eq $true ) {
    _DetectBorders $file
}
_job88

Read-Host -Prompt "After _job88"

Start-Process -FilePath $EncodingServer -WindowStyle Minimized
Start-Sleep -Seconds 1
Start-Process -FilePath $EncodingServer -WindowStyle Minimized
Start-Sleep -Seconds 1
Start-Process -FilePath $EncodingServer -WindowStyle Minimized
Start-Sleep -Seconds 1
Start-Process -FilePath $EncodingServer -WindowStyle Minimized
Start-Sleep -Seconds 10




if ($skipnorm -eq $true) {
    $procs = $((Start-Process -FilePath $SubtitleEdit -ArgumentList ('/convert "' + ($path + '\' + $file.BaseName + '_demux\') + '*.sup" subrip /ocrengine:tesseract /FixCommonErrors /RemoveTextForHI /RedoCasing /FixCommonErrors /FixCommonErrors /outputfolder:"' + $remuxpath) -WorkingDirectory $remuxpath  -PassThru -NoNewWindow); (Start-Process -FilePath $EncodingClient -ArgumentList ('"' + $temppath + '\job88_EncodingClient.meta"')  -PassThru ))
    
} else {
	$audiofile = Get-Childitem -LiteralPath $demuxpath -Include ('*.dts', '*.ac3')
    _WrapAudio $audiofile[0]
    Export-Function -Function _Normalize -OutPath ".\"
    $procs = $((Start-Process "pwsh" -ArgumentList ('-File .\_Normalize.ps1 "' + $mkvfile + '" "' + $bitrate + '" "' + $freq + '" "' + $codec + '" "' + $audioext + '"')   -PassThru -NoNewWindow) ; (Start-Process -FilePath $SubtitleEdit -ArgumentList ('/convert "' + ($path + '\' + $file.BaseName + '_demux\') + '*.sup" subrip /ocrengine:tesseract /FixCommonErrors /RemoveTextForHI /RedoCasing /FixCommonErrors /FixCommonErrors /outputfolder:"' + $remuxpath) -WorkingDirectory $remuxpath  -PassThru -NoNewWindow); (Start-Process -FilePath $EncodingClient -ArgumentList ('"' + $temppath + '\job88_EncodingClient.meta"')  -PassThru ))
}
$procs.WaitForExit()
$procs | Wait-Process
Read-Host -Prompt "After skipnorm"

Start-Sleep -Seconds 6
stop-process -name EncodingServer -Force

if ($onlynorm -eq $false) {
    $AudioList = Get-ChildItem -LiteralPath $demuxpath -Include ("*.aac", "*.ac3", "*.dts", "*.eac3", "*.flac,", "*.mp1", "*.mp2", "*.mp3", "*.ogg") -ErrorAction SilentlyContinue -Force | Sort-Object
    $AudioList | Select-Object -First $Maxaudio | ForEach-Object { Move-Item -LiteralPath $_ -Destination $remuxpath }
}



_remux
#Remove-Item -LiteralPath $demuxpath -Force -Recurse -ErrorAction SilentlyContinue
#Remove-Item -LiteralPath $remuxpath -Force -Recurse -ErrorAction SilentlyContinue
#Remove-Item -LiteralPath $temppath -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -LiteralPath ".\_Normalize.ps1" -Force -Recurse -ErrorAction SilentlyContinue
