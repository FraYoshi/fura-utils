#!/bin/bash -
# TO READ HERE
# https://linuxize.com/post/bash-functions/

source ~/.config/furayoshi/ffmpeg/ffmpeg.sh

main () {
    check $@

    while true;
    do sleep $seconds;
       count=$(printf "%0.6i" "$lastFrame");
       ffmpeg -f x11grab -s $format -i $DISPLAY+$coord -frames:v 1 "$output$count.$ext";
       lastFrame=$((lastFrame+1));
    done
}

check () {
    local OPTIND opt i
    while getopts ":tscone:" opt; do
	case $opt in
	    t) seconds_func;;
	    s) format_func;;
	    c) coord_func;;
	    o) output_func;;
	    n) lastFrame_func;;
	    e) ext_func;;
	    \?) help;exit 1 ;;
	esac
    done
    shift $((OPTIND -1))
}

seconds_func () {
    seconds="$OPTARG"
    if [[ $seconds == "" ]]; then
	echo "no seconds defined [0.25/1/...]"
    fi
}

format_func () {
    format="$OPTARG"
    if [[ $format == "" ]]; then
	echo "no format defined [qcif/1920x1080/3840x2160/...]"
    fi
}

coord_func () {
    coord="$OPTARG"
    if [[ $coord == "" ]]; then
	echo "no coordinates specified [0,0/1920,1080/...]"
	echo "find with the xrandr command"
    fi
}

output_func () {
    output="$OPTARG"
    if [[ $output == "" ]]; then
	echo "no output filename specified [timelapse_]"
    fi
}

lastFrame_func () {
    lastFrame="$OPTARG"
    if [[ $lastFrame == "" ]]; then
	echo "no last frame specified [1] default with no zeros"
    fi
}

ext_func () {
    ext="$OPTARG"
    if [[ $ext == "" ]]; then
	echo "no extension defined [png/jpg/...]"
    fi
}

main $@

## START of TEST CODE

# to continue the progressive and not restart at 0, source the subshell
# . fura-timelapse
#
#if [[ `ls` ]]; then
#    echo "directory ""$PWD"" not empty, input last frame +1 (without the zeros) to continue"
#    read framen
#fi
#
#if [[ -z $DISPLAY ]]; then
#    echo  "input DISPLAY variable i.e. :0.0"
#    read DISPLAY
#fi
#
## SECONDS is an internal variable of Bash, avoid unless want to double time at each run.
#
#
#
#if [[ $2 ]]; then
#    coord=$2
##elif
#    [[ $coord ]]; then
#    coord=$coord
#else
#    echo -e "input desktop coordinates from xrandr. default is 0,0"
#    read coord
#fi
#
#if [[ $3 ]]; then
#    output=$3
#elif
#    [[ $output ]]; then
#    output=$output
#else
#    echo "input an output name i.e. timelapse_"
#    read $output
#fi
#
#if [[ $4 ]]; then
#    format=$4
#elif
#    [[ $format ]]; then
#    format=$format
#else
#    echo "input a format i.e. 1920x1080"
#    read $format
#fi

## END of TEST CODE
