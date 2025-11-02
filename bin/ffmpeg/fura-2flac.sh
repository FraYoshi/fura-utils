#!/bin/bash -

source ~/.config/furayoshi/ffmpeg/ffmpeg.sh

if [ $1 ]; then
    pattern="$1"
else
    echo -en "input case insensitive search pattern [i.e. *.wav]: "
    read pattern
fi

echo -en "save location is the same as the original file\n"
echo -en "WARNING: if the script ends before rearching 100%, you are likely to have some currupted files, check after error, repair/delete, and re-run the script\n"
echo -en "Audio will be converted from ""$pattern"" to flac and then DELETED. Continue?\n"
select whattodo in no check yes keep
do case $whattodo in
       "no")
	   echo "abort"
	   break
	   ;;
       "check")
	   find . -iname "$pattern" -print0 \
	       | parallel -0 --dry-run \
			  'echo "Converting: '"{}"'  →  '"{.}.flac"''
	   echo -n "you can now re-run the script"
	   break
	   ;;
       "yes")
	   SAVEIFS=$IFS
	   IFS=$(echo -en "\n\b")
	   find . -iname "$pattern" -print0 \
		   | parallel -0 --nice 10 -j$(nproc) \
			      --progress --bar \
			      --halt soon,fail=1 \
			      'ffmpeg -hide_banner -i '"{}"' \
			      -c:a flac -compression_level '"$FLAC_COMPRESSION_LV"' \
			      '"{.}.flac"' -y \
		   && touch -r '"{}"' '"{.}.flac"' \
		   && rm '"{}"''
	   IFS=$SAVEIFS
	   break
	   ;;
       "keep")
	   SAVEIFS=$IFS
	   IFS=$(echo -en "\n\b")
	   find . -iname "$pattern" -print0 \
		   | parallel -0 --nice 10 -j$(nproc) \
			      --progress --bar \
			      --halt soon,fail=1 \
			      'ffmpeg -hide_banner -i '"{}"' \
			      -c:a flac -compression_level '"$FLAC_COMPRESSION_LV"' \
			      '"{.}.flac"' -y \
		   && touch -r '"{}"' '"{.}.flac"''
	   IFS=$SAVEIFS
	   break
	   ;;
esac
done

# NOTES on Compression levels from https://www.reddit.com/r/audioengineering/comments/ceqtcd/comment/eu4tiqc/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button:
# Level 	Ratio 1 	Enc Time 1 	Dec Time 1 	Ratio 2 	Enc Time 2 	Dec Time 2
# 0 	        68.81%  	13.925s 	9.743s 	        67.39%  	8.499s  	6.050s
# 1 	        48.34%  	13.915s 	9.380s  	66.45%  	8.718s  	6.172s
# 2 	        48.33%  	14.977s 	9.452s  	66.27%  	9.696s  	6.248s
# 3 	        64.35%  	15.050s 	10.634s 	63.32%  	8.894s  	6.560s
# 4 	        41.44%  	15.560s 	10.467s 	61.01%  	10.071s 	6.907s
# 5 	        41.38%  	18.699s 	10.357s 	60.82%  	11.949s 	6.788s
# 6 	        41.13%  	28.537s 	10.406s 	60.44%  	18.227s 	6.802s
# 7 	        39.31%  	30.065s 	11.452s 	58.74%  	19.666s 	7.243s
# 8 	        39.24%  	44.671s 	11.249s 	58.62%  	29.723s 	7.225s 
