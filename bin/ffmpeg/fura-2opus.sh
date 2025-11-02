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
echo -en "Audio will be converted from ""$pattern"" to $OPUSEXT and then DELETED. Continue?\n"
select whattodo in no check yes keep
do case $whattodo in
       "no")
	   echo "abort"
	   break
	   ;;
       "check")
	   find . -iname "$pattern" -print0 \
	       | parallel -0 --dry-run \
			  'echo "Converting: '"{}"'  →  '"{.}.$OPUSEXT"''
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
			      -c:a libopus -b:a $OPUSBITRATE -vbr $OPUSVBR \
			      -af aformat=channel_layouts="$OPUSCHANNELLAYOUT" \
			      '"{.}.$OPUSEXT"' -y \
		   && touch -r '"{}"' '"{.}.$OPUSEXT"' \
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
			      -c:a libopus -b:a $OPUSBITRATE -vbr $OPUSVBR \
			      -af aformat=channel_layouts="$OPUSCHANNELLAYOUT" \
			      '"{.}.$OPUSEXT"' -y \
		   && touch -r '"{}"' '"{.}.$OPUSEXT"''
	   IFS=$SAVEIFS
	   break
	   ;;
esac
done
