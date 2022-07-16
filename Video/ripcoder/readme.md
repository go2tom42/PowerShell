# RIPCODER

#### A Powershell script stealing everything it can from RipBot264

Runs on Powershell 7, might work on Powershell 5 never tried, to try change on line 1269 "pwsh" to "powershell"

End goal gives RipBot264 GUI a CLI interface, plus a few bells and whistles like it normalizes the main audio file (EBU R128 loudness plus keeps original) and it creates a SRT from a SUP.

It is tailored to completely max out a CPU (I using a AMD 5950x), just using x264 would only use like 60% so here we are

**Requirements** 
- RipBot264v1.26.0 https://forum.doom9.org/showthread.php?t=127611  
- Subtitle Edit https://github.com/SubtitleEdit/subtitleedit/releases  
- MediaInfo CLI VERSION https://mediaarea.net/en/MediaInfo/Download/Windows  

 YOU NEED TO SET 3 VARIABLES, SEE LINE 229 in script

 **Basic Usage**

 ripcoder file [Path to file] 

#### Main Options  

#####  Audio normalizion Options  

-   `-codec ac3` [Audio for normalized file, **ac3** is default]
-   `-audioext ac3` [File extension for selected codec, **ac3** is default]
-   `-bitrate 192k` [Audio file bitrate, **192k** is default]
-   `-freq 48000` [Audio file frequency , **48000** is default]

#####  Video Options  

-   `-crf 20` [Constant Rate Factor, range 0 to 51, default is **20** ]  
-   `-level 4.0` [Options 1.0, 1.1, 1.2, 1.3, 2.0, 2.1, 2.2, 3.0, 3.1, 3.2, 4.0, 4.1, 4.2, 5.0, & 5.1. Default is **4.0**]  
-   `-preset veryslow` [Options ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow, & placebo. Default is **veryslow**]  
-   `-myprofile high` [Options baseline, main, & high. Default is **high**]  
-   `-tune none` [Options none, film, animation, grain, stillimage, psnr, ssim, fastdecode, & zerolatency. Default is **none**]  

#####  Extra Options  

#####  Resizing  

-    `-s2160` [Resize to 2160p]  
-    `-s1080` [Resize to 1080p]   
-    `-s720` [Resize to 720p]  
-    `-s576` [Resize to 576p]  
-    `-s480` [Resize to 480p]   

######   Cropping  

-    `-autocrop` [Audio crop black bars]  
-    `-crop` 'left,top,right,bottom' [Number of pixels to remove from listed direction, must be power of 2 (0 2 4 6 8 10 etc) (EX -crop '265,2,265,0'  )]  

######   Audio  

-    `-skipnorm` [Don't normalize audio]  
-    `-onlynorm` [only include normalized audio file, main audio track removed]  
-    `-Maxaudio` [Total number of audio files to include in final video, 9 is default)  

######   Color Convertion   

-    `-LPC` [TV -> PC]  
-    `-LTV` [PC -> TV]  
-    `-colors 'hue,sat,bright,cont'` [Hue -180 to 180 Whole Numbers, sat 0 to 2 by tenths,bright -255 to 255 Whole Numbers,cont  0 to 2 by tenths (EX -crop '265,2,265,0' )]  

######   Video Enhancements  

-    `-decimate` [decimate 29.97 to 23.976]  
-    `-tonemap` [Kepp HDR tone map]  
-    `-addborders` [Auto Borders for 16/9]  
-    `-interlace` [Interlaces video (why?)]  

######      Sharpen  

- ​      `-sh25` [Sharpen 25%]  
- ​      `-sh50` [Sharpen 50%]  
- ​      `-sh75` [Sharpen 75%]  
- ​      `-sh100` [Sharpen 100%]  

######      Degrain  

- ​      `-mdegrain1 400` [Denoise using MDegrain1, they value is for strength 100-800]  
- ​      `-mdegrain2 400` [Denoise using MDegrain2, they value is for strength 100-800]  
- ​      `-mdegrain3 400` [Denoise using MDegrain3, they value is for strength 100-800]  

######      Deinterlace  

- ​      `-IT` [Inverse Telecine]  
- ​      `-dBFF1x` [BFF keep same frame rate]  
- ​      `-dBFF2x` [BFF double frame rate]  
- ​      `-dTFF1x` [TFF keep same frame rate]  
- ​      `-dTFF2x` [TFF double frame rate]  
