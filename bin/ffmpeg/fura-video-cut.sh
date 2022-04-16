#!/bin/bash -
source ~/.config/furayoshi/ffmpeg/ffmpeg.sh

input=$1

if [ $2 ] && [ $3 ]; then
    start=$2
    end=$3
elif [ $2 ] && [ $3 != 0 ]; then
    start=$2
    echo "start set on $start"
    echo "input end time [format hh:mm:ss.dddd]: "
    read end
else
    echo "input the start time [format hh:mm:ss.dddd]: "
    read start
    echo "input end time [format hh:mm:ss.dddd]: "
    read end
fi
echo -en "cutting video $input from $start to $end in "\""$PWD"\"" \nproceed?\n"
select yesno in yes no
do case $yesno in
       "no")
	   echo "abort"
	   break
	   ;;
       "yes")
	   ffmpeg -hide_banner -ss $start -to $end -i "$input" -c copy "${input%.*}""$CUTSUFFIX".${input#*.} \
	       && touch -r "$input" "${input%.*}""$CUTSUFFIX".${input#*.}
	   echo "end of script"
	   break
	   ;;
   esac
done
