#!/bin/bash -

source ~/.config/furayoshi/ffmpeg/ffmpeg.sh

if [ $1 ]; then
    pattern="$1"
else
    echo -en "input case insensitive search pattern [i.e. *.wav]: "
    read pattern
fi

if [ $2 ]; then
    whattodo="$2"
else
    echo -en "save location is the same as the original file\n"
    echo -en "WARNING: if the script ends before rearching 100%, you are likely to have some currupted files, check after error, repair/delete, and re-run the script\n"
    echo -en "Audio will be converted from ""$pattern"" to $OPUSEXT and then DELETED. Continue?\n"
    select whattodo in no check yes keep; do
	[ -n "$whattodo" ] && break
    done
fi

case $whattodo in
       "no")
	   echo "abort"
	   ;;
       "check")
	   find . -iname "$pattern" -print0 \
	       | parallel -0 --dry-run \
			  ''"{}"'  →  '"{.}.$OPUSEXT"''
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
	   ;;
       *)
	   echo "$2"" is invalid, select a valid option. Valid options are: no check yes keep" >&2
	   exit 1
	   ;;
esac
