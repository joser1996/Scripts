#!/bin/bash

INPUT=$1 #Pass in csv file as first argument
VIDEOFILE=$2 #Video file from which audio will  be ripped
AUDIOFILE='tempAudio.mp3'
OLDIFS=$IFS
IFS=','

#Check to see if correct number of arguments
if [[ $# -ne 2 ]]; then
	{ echo "Illegal number of parameters"; exit 99; }
fi

[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; } #-f returns true to see if file exists and is regular;
##&& Ensures that second command is only executed if the first one returns a success

#First rip the audio from the Video
echo "Ripping audio from $VIDEOFILE"
ffmpeg -i "$VIDEOFILE" -ab 320k "$AUDIOFILE" # -loglevel debug

PID=$!
waid PID

echo "Checking to see if temp audio file exists"
[ ! -f $AUDIOFILE ] && { echo "$AUDIOFILE file not found"; exit 99; }


while read songTitle startTime endTime
do
	echo -e "Name:\t $songTitle"
	echo -e "Start:\t $startTime"
	echo -e "End:\t $endTime\n\n"

#	echo "Converting startTime to seconds"
	IFS=':'

	read -ra startARR <<< "$startTime"
	read -ra endARR <<< "$endTime"
	IFS=','

	hour=${startARR[0]}
	min=${startARR[1]}
	sec=${startARR[2]}
	startSecs=$((10#$hour*60*60 + 10#$min*60 + 10#$sec))
#	echo "Start time in Secs: ${startSecs}"

	hour=${endARR[0]}
	min=${endARR[1]}
	sec=${endARR[2]}
	endSecs=$((10#$hour*60*60 + 10#$min*60 + 10#$sec))
#	echo "End time in Secs : ${endSecs}"

	interval=$(($endSecs - $startSecs))
#	echo "Interval: $interval"

	# $1 csv file
	# $2 input audio file
	#songTitle=${songTitle%\"*}
	extension=.mp3
	songTitle=$songTitle$extension
	echo "Song Name: $songTitle"
	echo "Command: ffmpeg -nostdin -ss $startSecs -t $interval  -i $AUDIOFILE -ab 320k $songTitle"
	ffmpeg -nostdin -ss $startSecs -t $interval -i $AUDIOFILE -ab 320k $songTitle;
	PID=$!
	wait $PID

done < $INPUT

#Clean up
rm -f $AUDIOFILE

IFS=$OLDIFS
