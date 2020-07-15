#!/bin/sh


text=$1
video=$2

videoname=$(basename $video .mp4)

starting=($(cut -f1 $text))
ending=($(cut -f2 $text))

output=$3

for ((i=0;i<${#starting[@]};++i))
do

	fs=$[ ${starting[i]%.*} - 1 ]
	if [ ${fs} -lt 0 ]
	then
		fs=0
	fi
	echo "$fs, ${starting[i]}, ${ending[i]} :("
	ffmpeg -loglevel -8 -i $video -ss ${starting[i]} -to ${ending[i]} -f wav -acodec pcm_s16le -ac 1 -ar 16k $output${videoname//_/-}-$i.wav
done
