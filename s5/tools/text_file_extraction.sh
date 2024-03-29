#!/bin/sh


text=$1
video=$2

videoname=$(basename $video .mp4)

SAVEIFS=$IFS   # Save current IFS
IFS=$'\n'      # Change IFS to new line

text=($(cut -f3 $text))

IFS=$SAVEIFS   # Restore IFS

for ((i=0;i<${#text[@]};++i))
do
	echo "${videoname//_/-}-$i ${text[i]^^}"
done >> $3
