#!/bin/bash -

source ~/.config/furayoshi/ffmpeg/ffmpeg.sh

if [ $1 ]; then
    pattern="$1"
else
    echo -en "input case insensitive search pattern [i.e. *.wav]: "
    read pattern
fi

echo -en "save location is the same as the original file\n"
echo -en "Audio will be converted from ""$pattern"" to $OPUSEXT and then DELETED. Continue?\n"
select whattodo in no yes keep
do case $whattodo in
       "no")
	   echo "abort"
	   break
	   ;;
       "yes")
	   SAVEIFS=$IFS
	   IFS=$(echo -en "\n\b")
	   for audio in $(find . -iname "$pattern"); do
	       ffmpeg -hide_banner -i "$audio" -c:a libopus -b:a $OPUSBITRATE -vbr $OPUSVBR -af aformat=channel_layouts="$OPUSCHANNELLAYOUT" "${audio%.*}".$OPUSEXT -y \
		   && touch -r "$audio" "${audio%.*}".$OPUSEXT \
		   && rm "$audio";
	   done
	   IFS=$SAVEIFS
	   break
	   ;;
       "keep")
	   SAVEIFS=$IFS
	   IFS=$(echo -en "\n\b")
	   for audio in $(find . -iname "$pattern"); do
	       ffmpeg -hide_banner -i "$audio" -c:a libopus -b:a $OPUSBITRATE -vbr $OPUSVBR -af aformat=channel_layouts="$OPUSCHANNELLAYOUT" "${audio%.*}".$OPUSEXT -y \
		   && touch -r "$audio" "${audio%.*}".$OPUSEXT;
	   done
	   IFS=$SAVEIFS
	   break
	   ;;
esac
done
