# Normalize.default.audio.track.ps1

A script for normalizing Default audio track

Contents:

- [Requirements](#requirements)
- [Usage](#usage)
- [Description](#description)
- [Example](#example)

-------------

## Requirements

-   Python 2.7 or 3
-   ffmpeg v3.1 or above from <http://ffmpeg.org/> installed in your \$PATH
-   ffmpeg-normalize run on python, can be compiled into EXE if needed
    https://github.com/slhck/ffmpeg-normalize

## Usage

    .\Normalize.default.audio.track.ps1 [-File Video] [-FFN ffmpeg-normalize commands]

## Description

Please read this section for a high level introduction.

**What does the program do?**

The script uses [FFprobe](http://ffmpeg.org) to find the default audio track in your video.  If no track has the "Default" tag if picks the first audio track listed in the video file.  Then it uses [FFmpeg](http://ffmpeg.org) to demux the one audio track

The script cleans up and deletes the demuxed & normalized audio files when it finished

A new file is created when all is done. Say you started with yourfile.mkv, the finished file will be named yourfile.normalized.mkv.  The original file IS NOT deleted, I'm not that sure of the powershell skills.  Verify the file is correct and delete the 

**How do I specify the input?**

This script accepts two arguments, the file (required) and the commands you would use for **[ffmpeg-normalize](https://github.com/slhck/ffmpeg-normalize)**

-File c:\directory\file.mkv

-FFN '-v -ext m4a -c:a aac -b:a 192k -pr -e="-ac 2"'

If you don't supply a -FFN the one listed above is what you will get

## Example

Normalize default track use AAC at 192k, it also downmixes audio to two channels:

    .\Normalize.default.audio.track.ps1 -File "c:\ Folder with spaces\video.mkv" -FFN '-v -ext m4a -c:a aac -b:a 192k -pr -e="-ac 2"'

-File for locations with spaces use " " or ' ' around it

-FFN use ' ' around the command if it contains any " ", if not use either