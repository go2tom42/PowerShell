if ($args.count -ne 0) {
    $URLs = $args[0]
} else {
    $URLFile = @"
https://www.cbs.com/shows/star_trek_the_next_generation/video/BFQkB7Vt7qKvz_YVWa0gtfXLkwF94JoW/star-trek-the-next-generation-descent-part-2/
https://www.cbs.com/shows/star_trek_the_next_generation/video/DoQsSs0prYs3k_E0qmy1VXts5bOQYqID/star-trek-the-next-generation-liaisons/
https://www.cbs.com/shows/star_trek_the_next_generation/video/PptPOUR_hfLhkYgi9HIgs_AxQdOiWuRL/star-trek-the-next-generation-interface/
https://www.cbs.com/shows/star_trek_the_next_generation/video/gs24HeXhqGpICA_OLAlMF6y_189mQITb/star-trek-the-next-generation-gambit-part-1/
https://www.cbs.com/shows/star_trek_the_next_generation/video/lTmf27flvhSUp1UyHL_lRbxozL9xdWFC/star-trek-the-next-generation-gambit-part-2/
https://www.cbs.com/shows/star_trek_the_next_generation/video/bZi2CxajYhnY5dh7M2uODWFVs_vsdek_/star-trek-the-next-generation-phantasms/
https://www.cbs.com/shows/star_trek_the_next_generation/video/NLOExr61_i7Mi9_8DI_U_lNBOZTFF4hT/star-trek-the-next-generation-dark-page/
https://www.cbs.com/shows/star_trek_the_next_generation/video/e0uZ90KlbGsl0vN9U_ObFdSD3llRonYt/star-trek-the-next-generation-attached/
https://www.cbs.com/shows/star_trek_the_next_generation/video/fWaJYTeUS9ihoCpcuJYPL7UsrCnPkYq5/star-trek-the-next-generation-force-of-nature/
https://www.cbs.com/shows/star_trek_the_next_generation/video/Ts8cuQVmHgBoE1t0FFWiZOzPAGqxxfvo/star-trek-the-next-generation-inheritance/
https://www.cbs.com/shows/star_trek_the_next_generation/video/tppc_sDtxEeN7HEQ2ksIH4XcsQ0lriHU/star-trek-the-next-generation-parallels/
https://www.cbs.com/shows/star_trek_the_next_generation/video/C_dTMShWiitT7GkaDBK_uWZQEBPR1k6_/star-trek-the-next-generation-the-pegasus/
https://www.cbs.com/shows/star_trek_the_next_generation/video/miga_maWuSlAqdQSPokWKH4NhTbJTlxM/star-trek-the-next-generation-homeward/
https://www.cbs.com/shows/star_trek_the_next_generation/video/yBOajCgAeu_y3xTrl04kcnlbZrMaCjxz/star-trek-the-next-generation-sub-rosa/
https://www.cbs.com/shows/star_trek_the_next_generation/video/l_qg7_XTcWHOCGzIHm48MGQTjbtCEg8K/star-trek-the-next-generation-lower-decks/
https://www.cbs.com/shows/star_trek_the_next_generation/video/sU0regOf42ybDXWq3OjrBUGOfDkBuAWZ/star-trek-the-next-generation-thine-own-self/
https://www.cbs.com/shows/star_trek_the_next_generation/video/qRCWaRpq2QdohBPO_x1GQ8cdgfn6oqIE/star-trek-the-next-generation-masks/
https://www.cbs.com/shows/star_trek_the_next_generation/video/GSBn6GuNZi7xQUWMgxviG_dox0hMsx4d/star-trek-the-next-generation-eye-of-the-beholder/
https://www.cbs.com/shows/star_trek_the_next_generation/video/WTG1lB9tFbPn1i6Qo3dO9dsY9AcAyVn1/star-trek-the-next-generation-genesis/
https://www.cbs.com/shows/star_trek_the_next_generation/video/__ky0_PIQWocqJXVxSkyouPAfGvpeUKv/star-trek-the-next-generation-journey-s-end/
https://www.cbs.com/shows/star_trek_the_next_generation/video/ZBW44pJubmAcFzzkr2lw2BOU4kZHuYEC/star-trek-the-next-generation-firstborn/
https://www.cbs.com/shows/star_trek_the_next_generation/video/qaLRFTK0iSjFcvL9h2o6IbyrR_YT_mNP/star-trek-the-next-generation-bloodlines/
https://www.cbs.com/shows/star_trek_the_next_generation/video/DXiCyuhXsLGQmDBqs_jZjRv89cmHAoOb/star-trek-the-next-generation-emergence/
https://www.cbs.com/shows/star_trek_the_next_generation/video/HpuHVl_7YmkDPgZKFgjtDR7bzt7blvth/star-trek-the-next-generation-preemptive-strike/
https://www.cbs.com/shows/star_trek_the_next_generation/video/TenM2_ENhqQxbaatKhfbw2n6vMZp81iM/star-trek-the-next-generation-all-good-things-part-1-of-2/
https://www.cbs.com/shows/star_trek_the_next_generation/video/2HBUgj80Nd6tQBtGfT7sOBbK3xSaAqKc/star-trek-the-next-generation-all-good-things-part-2-of-2/
"@
    $URLs = $URLFile -split "`n";
    $savedPages = @();
}
    

$UserCount = 0
foreach($url in $URLs) 
{
    # Limit 5 downloads at once
    if(++$UserCount % 5 -eq 0) 
    {
        Wait-Process -Name youtube-dl
    }
    #CBS.com's 1080p videos are bitstarved
	Start-Process -FilePath "youtube-dl" -ArgumentList ('--cookies c:\scripts\cookies.txt -f "best[height=720]" ' + $url)
}