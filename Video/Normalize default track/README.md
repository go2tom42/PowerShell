# Normalize.default.audio.track.ps1

A script for normalizing Default audio track

Contents:

- [Requirements](#requirements)
- [Usage](#usage)
- [Description](#description)
- [Example](#example)
- [TO-DO](#TO-DO)

-------------

## Requirements

-   MKVmerge <https://www.matroska.org/> installed in your \$PATH
-   ffmpeg v3.1 or above from <http://ffmpeg.org/> installed in your \$PATH

## Usage

    .\Normalize.default.audio.track.ps1 [-File Video] [-c AUDIO_CODEC] [-b AUDIO_BITRATE] [-ar SAMPLE_RATE] [-ext EXTENSION]

## Description

Please read this section

**What does the program do?**

The script uses [MKVmerge](https://www.matroska.org) to find the default audio track in your video.  If no track has the "Default" tag if picks the first audio track listed in the video file.  Then it uses [MKVmerge](https://www.matroska.org) to demux the one audio track

That extracted audio file is normalized to  [EBU R128](https://tech.ebu.ch/docs/tech/tech3341.pdf) standard using loudnorm via ffmpeg

The normalized audio file is then remuxed back into the video, it will have the "Default" tag & be the 1st audio track in the video. 

When all id don you will have a new file. Say you started with yourfile.mkv, the finished file will be named yourfile.NORMALIZED.mkv. The original file IS NOT deleted incase something went wrong. (you can uncomment last line to remove original file 

## Examples

Normalize default track use ac3 at 384k, it also downmixes audio to two channels:

    .\Normalize.default.audio.track.ps1 "c:\ Folder with spaces\video.mkv"
    .\Normalize.default.audio.track.ps1 -File "c:\ Folder with spaces\video.mkv" -c aac -ext aac -b 190k -ar 480000

## TO-DO

Add progressbars
