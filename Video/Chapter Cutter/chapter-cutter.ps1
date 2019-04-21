#source https://github.com/soko-no-otaku/chapter-cutter/blob/master/chapter-cutter.ps1

$source  = $args[0]
$start_chapter = $args[1]
if ($args.Length -eq 2) {
    $end_chapter = $start_chapter
} else {
    $end_chapter = $args[2]
}

$output_filename = (Read-Host "Please enter output file name") + ".mp4"

$chapter_list = (ffprobe.exe -print_format json -show_chapters $source | ConvertFrom-Json)[0].chapters

$start_time = $chapter_list[$start_chapter - 1].start_time
$end_time   = $chapter_list[$end_chapter - 1].end_time
$duration   = $end_time - $start_time

ffmpeg.exe -ss $start_time -i $source -t $duration $output_filename
