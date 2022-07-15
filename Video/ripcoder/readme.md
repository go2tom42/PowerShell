Ends goal gives RipBot264 GUI a CLI interface, plus a few bells and whistles like it normalizes the main audio file (and keeps original) and it creates at SRT from a SUP.

 It is tailored to completely max out a CPU (I using a AMD 5950x), just using x264 would only use like 60% so here we are

 **Requirements** 

 RipBot264v1.26.0 https://forum.doom9.org/showthread.php?t=127611
 Subtitle Edit https://github.com/SubtitleEdit/subtitleedit/releases
 MediaInfo CLI VERSION https://mediaarea.net/en/MediaInfo/Download/Windows

 YOU NEED TO SET 3 VARIABLES, SEE LINE 121 in script

 **Usage**
 ```
 -File [Path to file] 
 Audio normalizion Options
  -codec [Audio for normailzed file, ac3 is default]
  -audioext [File extention for selected codec, ac3 is default]
  -bitrate [Audio file bitrate, 192k is default]
  -freq [Audio file frequency , 48000 is default]
  -skipnorm [Don't normalize audio]
  -onlynorm [only include normalized audio file]
  -Maxaudio [Total number of audio files to include in final video, 9 is default)

 Video Options`
  -crf [Constant Rate Factor, range 0 to 51, default is 20 ]`
  -level [Options 1.0, 1.1, 1.2, 1.3, 2.0, 2.1, 2.2, 3.0, 3.1, 3.2, 4.0, 4.1, 4.2, 5.0, & 5.1. Default is 4.0]`
  -preset [Options ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow, & placebo. Default is veryslow]`
  -myprofile [Options baseline, main, & high. Default is high]`
  -tune [Options none, film, animation, grain, stillimage, psnr, ssim, fastdecode, & zerolatency. Default is none]`
  -s720 [Resize to 720p]` 
  -autocrop [Audio crop black bars] 
  ```

 Examples
  `ripcoder "C:\Vi deo\P&R\s02e15.mkv" -crf 16 -preset veryslow -profile main`
