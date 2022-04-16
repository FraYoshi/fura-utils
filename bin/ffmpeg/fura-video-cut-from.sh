#!/bin/bash -
source ~/.config/furayoshi/ffmpeg/ffmpeg.sh

input=$1

if [ $2 ]; then
    start=$2
else
    echo "input the start time [format hh:mm:ss.dddd]: "
    read start
fi
echo -en "cutting video $input from $start to the end in "\""$PWD"\"" \nproceed?\n"
select yesno in yes no
do case $yesno in
       "no")
	   echo "abort"
	   break
	   ;;
       "yes")
	   ffmpeg -hide_banner -ss $start -i "$input" -c copy "${input%.*}""$CUTSUFFIX".${input#*.} \
	       && touch -r "$input" "${input%.*}""$CUTSUFFIX".${input#*.}
	   echo "end of script"
	   break
	   ;;
   esac
done
